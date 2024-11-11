function [out] = fit_model_circinf(dat,varargin)
%  FIT_MODEL_CIRCINF  Fit circular inference model based on sequences of
%  orientation samples to orientation estimation reports with distinct sources
%  of internal noise
%
%  Usage: [out] = FIT_MODEL_CIRCINF(dat,...)
%
%  where dat is a data structure that needs to contain the following fields:
%  kappa is the generative sequence coherence, seqang is a cell array containing
%  the sequence orientation samples (expressed in degrees modulo pi), and resp
%  is an array containing the orientation estimation reports to be fitted
%  (estimated in degrees modulo pi). Leave resp empty when you want to use the
%  function to simulate (rather than fit) the model.
%
%  The fitting procedure relies on the Bayesian Adaptive Direct Search (BADS)
%  toolbox developed by Luigi Acerbi (https://github.com/acerbilab/bads). Make
%  sure to change the badspath variable to wherever the toolbox is found on your
%  machine.
%
%  The function can take optional name-value arguments: nsmp is the number of
%  particles, nval is the number of validation samples, nrun is the number of
%  random starting points, epsi is the infinitesimal response probability (used
%  to avoid numerical errors), and verbose is the fitting display level (from 0
%  for silent fitting to 2 for iteration-wise verbose fitting).
%
%  The model has 5 free parameters:
%    * alpha  = inference imbalance (>0:recency, <0:primacy)
%    * sigsen = sensory noise (expressed in degrees modulo pi)
%    * siginf = inference noise (expressed in evidence units)
%    * sigrep = reporting noise (expressed in degrees modulo pi)
%    * plapse = reporting lapse rate
%
%  Optional name-value arguments can also include *any* combination of the model
%  parameters, so that these parameters can be fixed to any arbitrary values and
%  not be fitted. When all model parameters are set to fixed values, the
%  function simulates model responses in out.rt and runs a particle filter to
%  recover best-fitting estimates of the latent variables used by the model: the
%  expected response in out.xt, the expected response coherence in out.kt, the
%  trajectory of inferred orientation in out.anginf (expressed in degrees modulo
%  pi), and the trajectory of inferred magnitude in out.maginf (expressed as
%  vector length).
%
%  When the model is fitted to orientation estimation reports, the function
%  returns best-fitting (maximum-likelihood) estimates of model parameter values
%  in the output structure out, along with quality-of-fit metrics (including AIC
%  and BIC values).
%
%  The function code should be sufficiently commented for it to be readable, and
%  even modifiable *at your own risk*. Otherwise, please send me a message at
%  the email address provided below.
%
%  Valentin Wyart <valentin.wyart@inserm.fr>

% % add circular statistics toolbox to path
% circpath = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/Toolboxes/CircStat/';
% addpath(circpath);
% 
% % add BADS toolbox to path
% badspath = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/Toolboxes/bads/';
% addpath(badspath);

% check number of input arguments
narginchk(1,inf);

% check data structure
assert(isfield(dat,'kappa'));
assert(isfield(dat,'seqang'));
assert(isfield(dat,'resp'));

% get experiment data
kappa  = dat.kappa; % generative sequence coherence
seqang = dat.seqang; % sequence orientation samples (expressed in degrees)
resp   = dat.resp; % response (expressed in degrees)

% get total number of trials
ntrl = numel(seqang);

% parse name-value arguments
ip = inputParser;
ip.StructExpand = true; % structure expansion
ip.KeepUnmatched = true; % keep unmatched arguments
ip.addParameter('nsmp',1e3,@(x)isnumeric(x)&&isscalar(x));
ip.addParameter('nval',1e2,@(x)isnumeric(x)&&isscalar(x));
ip.addParameter('nrun',1e1,@(x)isnumeric(x)&&isscalar(x));
ip.addParameter('epsi',realmin,@(x)isnumeric(x)&&isscalar(x)&&x>=0);
ip.addParameter('verbose',0,@(x)isscalar(x)&&ismember(x,[0,1,2]));
ip.parse(varargin{:});

% create configuration structure
cfg = merge_struct(ip.Results,ip.Unmatched);

% get fitting parameters
nsmp    = cfg.nsmp;    % number of particles
nval    = cfg.nval;    % number of validation samples
nrun    = cfg.nrun;    % number of random starting points
epsi    = cfg.epsi;    % infinitesimal response probability
verbose = cfg.verbose; % fitting display level

% define model parameters
pnam = cell(1,5); % name
pmin = nan(1,5);  % minimum value
pmax = nan(1,5);  % maximum value
pini = nan(1,5);  % initial value
pplb = nan(1,5);  % plausible lower bound
ppub = nan(1,5);  % plausible upper bound
% 1/ inference imbalance (>0:recency, <0:primacy)
pnam{1} = 'alpha';
pmin(1) = -5;
pmax(1) = +5;
pini(1) = 0;
pplb(1) = -1;
ppub(1) = +1;
% 2/ sensory noise (expressed in degrees)
pnam{2} = 'sigsen';
pmin(2) = 0;
pmax(2) = 100;
pini(2) = 10;
pplb(2) = 1;
ppub(2) = 50;
% 3/ inference noise (expressed in evidence units)
pnam{3} = 'siginf';
pmin(3) = 0;
pmax(3) = 10;
pini(3) = 1;
pplb(3) = 0.1;
ppub(3) = 5;
% 4/ reporting noise (expressed in degrees)
pnam{4} = 'sigrep';
pmin(4) = 1e-3;
pmax(4) = 100;
pini(4) = 10;
pplb(4) = 1;
ppub(4) = 50;
% 5/ reporting lapse rate
pnam{5} = 'plapse';
pmin(5) = 0;
pmax(5) = 1;
pini(5) = 0.01;
pplb(5) = 0.001;
ppub(5) = 0.1;

% set number of parameters
npar = numel(pnam);

% apply user-defined initialization values
if isfield(cfg,'pini')
    for i = 1:npar
        if isfield(cfg.pini,pnam{i}) && ~isnan(cfg.pini.(pnam{i}))
            % clamp initialization value within plausible bounds
            pini(i) = cfg.pini.(pnam{i});
            pini(i) = min(max(pini(i),pplb(i)+1e-6),ppub(i)-1e-6);
        end
    end
end

% define fixed parameters
pfix = cell(1,npar);
for i = 1:npar
    if isfield(cfg,pnam{i}) && ~isempty(cfg.(pnam{i}))
        if ~isnan(cfg.(pnam{i}))
            pfix{i} = min(max(cfg.(pnam{i}),pmin(i)),pmax(i));
        else
            pfix{i} = cfg.(pnam{i});
        end
    end
end

% define free parameters
ifit = cell(1,npar);
pfit_ini = [];
pfit_min = [];
pfit_max = [];
pfit_plb = [];
pfit_pub = [];
n = 1;
for i = 1:npar
    if isempty(pfix{i}) % free parameter
        ifit{i} = n;
        pfit_ini = cat(2,pfit_ini,pini(i));
        pfit_min = cat(2,pfit_min,pmin(i));
        pfit_max = cat(2,pfit_max,pmax(i));
        pfit_plb = cat(2,pfit_plb,pplb(i));
        pfit_pub = cat(2,pfit_pub,ppub(i));
        n = n+1;
    end
end

% set number of fitted parameters
nfit = length(pfit_ini);

if nfit > 0
    
    % make sure responses are present
    if isempty(resp)
        error('Cannot fit the model without responses in the data structure!');
    end
    
    % configure BADS
    options = bads('defaults');
    options.UncertaintyHandling = true; % noisy objective function
    options.NoiseFinalSamples = nval; % number of samples
    switch verbose % display level
        case 0, options.Display = 'none';
        case 1, options.Display = 'final';
        case 2, options.Display = 'iter';
    end
    
    % fit model using multiple random starting points
    fval   = nan(1,nrun);
    xhat   = cell(1,nrun);
    output = cell(1,nrun);
    for irun = 1:nrun
        done = false;
        while ~done
            % set random starting point
            n = 1;
            for i = 1:npar
                if isempty(pfix{i}) % free parameter
                    % sample starting point uniformly between plausible bounds
                    pfit_ini(n) = unifrnd(pplb(i),ppub(i));
                    n = n+1;
                end
            end
            % fit model using BADS
            [xhat{irun},fval(irun),exitflag,output{irun}] = ...
                bads(@(x)getnll(x), ...
                pfit_ini,pfit_min,pfit_max,pfit_plb,pfit_pub,[],options);
            if exitflag > 0
                done = true;
            end
        end
    end
    ll_run    = -fval;
    ll_sd_run = cellfun(@(s)getfield(s,'fsd'),output);
    xhat_run  = xhat;
    % find best fit among random starting points
    [fval,irun] = min(fval);
    xhat   = xhat{irun};
    output = output{irun};
    
    % get best-fitting values
    phat = getpval(xhat);
    
    % create output structure with best-fitting values
    out = cell2struct(phat(:),pnam(:));
    
    % store full list of model parameters
    out.pnam = pnam;
    
    % store fitting information
    out.fitalgo = 'bads'; % fitting algorithm
    out.version = bads('version'); % version of fitting algorithm
    out.nsmp    = nsmp; % number of particles
    out.nval    = nval; % number of validation samples
    out.nrun    = nrun; % number of random starting points
    out.ntrl    = ntrl; % number of trials
    out.nfit    = nfit; % number of fitted parameters
    
    % get maximum log-likelihood
    out.ll = -output.fval; % estimated log-likelihood
    out.ll_sd = output.fsd; % estimated s.d. of log-likelihood
    
    % get complexity-penalized fitting metrics
    out.aic = -2*out.ll+2*nfit+2*nfit*(nfit+1)/(ntrl-nfit+1); % AIC
    out.bic = -2*out.ll+nfit*log(ntrl); % BIC
    
    % get parameter values
    out.xnam = pnam(cellfun(@isempty,pfix));
    out.xhat = xhat;
    
    % get run-specific output
    out.ll_run    = ll_run(:); % estimated log-likelihood
    out.ll_sd_run = ll_sd_run(:); % estimated s.d. of log-likelihood
    out.xhat_run  = cat(1,xhat_run{:}); % parameter values
    
    % store additional output from BADS
    out.options = options;
    out.output = output;
    
else
    
    % use fixed parameter values
    phat = getpval([]);
    
    % create output structure
    out = cell2struct(phat(:),pnam(:));
    
    % store filtering and simulation information
    out.nsmp = nsmp; % number of particles
    out.ntrl = ntrl; % number of trials
    out.nfit = 0; % no fitted parameter
    
    if nsmp > 0
        % get simulated responses and filtered latent variables
        [pt,rt,zt] = getp(phat{:});
        out.rt = rt; % simulated responses
        if ~isempty(resp)
            out.zt = zt; % filtered complex evidence trajectories
            % compute inferred orientation and coherence
            anginf = cell(ntrl,1); % inferred orientation (expressed in degrees)
            cohinf = cell(ntrl,1); % inferred coherence (expressed as vector length)
            for itrl = 1:ntrl
                anginf{itrl} = mod(angle(mean(zt{itrl}./abs(zt{itrl}),2))/2/pi*180,180)';
                cohinf{itrl} = mean(abs(zt{itrl}),2)';
            end
            out.anginf = anginf;
            out.cohinf = cohinf;
        end
    end
    
end

% store configuration structure
out.cfg = cfg;

    function [pval] = getpval(p)
        % get parameter values
        pval = cell(1,npar);
        for k = 1:npar
            if isempty(pfix{k}) % free parameter
                pval{k} = p(ifit{k});
            else % fixed parameter
                pval{k} = pfix{k};
            end
        end
    end

    function [nll] = getnll(p)
        % get parameter values
        pval = getpval(p);
        % get negative log-likelihood
        nll = -getll(pval{:});
    end

    function [ll] = getll(varargin)
        % compute response probability
        p = getp(varargin{:});
        % compute log-likelihood
        ll = sum(log(max(p,epsi)));
    end

    function [pt,rt,zt] = getp(alpha,sigsen,siginf,sigrep,plapse)
        pt = nan(ntrl,1);    % response probability
        rt = nan(ntrl,nsmp); % simulated responses
        zt = cell(ntrl,1);   % filtered complex evidence trajectories
        for itrl = 1:ntrl
            nang = numel(seqang{itrl});
            % sample particles
            z = complex(zeros(1,nsmp));
            zt{itrl} = nan(nang,nsmp);
            for iang = 1:nang
                % account for possible recency effect
                z = z*exp(-max(alpha,0));
                % account for sensory noise (expressed in degrees)
                a = seqang{itrl}(iang)+sigsen*randn(1,nsmp);
                % add evidence while accounting for possible primacy effect
                z = z+kappa*exp(1i*a*2*pi/180)*exp(+min(alpha,0)*(iang-1));
                % account for inference noise (expressed in evidence units)
                z = z+siginf*complex(randn(1,nsmp),randn(1,nsmp));
                zt{itrl}(iang,:) = z;
            end
            % account for reporting noise (expressed in degrees)
            x = mod(angle(z)+sigrep*randn(1,nsmp)*2*pi/180,2*pi);
            if ~isempty(resp) && ~isnan(resp(itrl))
                % get response probability
                [tpar,kpar] = circ_vmpar(x);
                pt(itrl) = circ_vmpdf(resp(itrl)*2*pi/180,tpar,kpar);
                pt(itrl) = (1-plapse)*pt(itrl)+plapse/2/pi;
            end
            if nargout > 1
                % get simulated responses
                rt(itrl,:) = x/2/pi*180;
                islapse = rand(1,nsmp) < plapse;
                rt(itrl,islapse) = rand(1,nnz(islapse))*180;
                if ~isempty(resp) && ~isnan(resp(itrl))
                    % get filtered complex evidence trajectories
                    y = mod((resp(itrl)+sigrep*randn(1,nsmp))*2*pi/180,2*pi);
                    [tpar,kpar] = circ_vmpar(y);
                    wt = circ_vmpdf(x,tpar,kpar);
                    if any(isnan(wt))
                        warning('Unstable particle filtering at trial %d.',itrl);
                        wt(isnan(wt)) = 0;
                    end
                    if nnz(wt) > 0
                        wt = wt/sum(wt);
                    else
                        wt(:) = 1/nsmp;
                    end
                    ismp = randsample(nsmp,nsmp,true,wt);
                    zt{itrl} = zt{itrl}(:,ismp);
                end
            end
        end
    end

end
function [r,r_c95] = circcorr(x1,x2,nd)
%  CIRCCORR  Circular correlation coefficient metric with better statistical
%  properties than circ_corrcc from the Circular Statistics toolbox
%
%  Usage: [r,r_c95] = CIRCCORR(x1,x2,[nd],[nres])
%
%  where x1 and x2 are two circular variables defined modulo 2*pi, and r is the
%  correlation coefficient metric. The optional input argument nd defines how
%  many shifted correlation coefficients are computed to extract their mean (the
%  default being 100).
%
%  The correlation coefficient metric r does not depend on the number of data
%  points, does not depend on the means of circular variables x1 and x2, and
%  does not depend on the mean tilt between x1 and x2. The circular correlation
%  coefficient from the Circular Statistics toolbox does not match these very
%  important properties.
%
%  The correlation coefficient metric r is defined in ]0,1] and does not
%  differentiate between an absence of circular correlation between x1 and x2
%  and a negative circular correlation between x1 and x2.
%
%  The function can also return a bootstrap estimate r_c95 of the 95% confidence
%  interval of the correlation coefficient metric r. The function uses nres
%  bootstrap resamples (the default being 1000). This obviously slows down the
%  function quite dramatically.
%
%  Valentin Wyart <valentin.wyart@ens.fr>

% check input arguments
if nargin < 4
    nres = 1e3;
end
if nargin < 3
    nd = 1e2;
end
if nargin < 2
    error('Missing input arguments!');
end
if numel(x1) ~= numel(x2)
    error('Mismatching input sizes!');
end

% columnize input arrays
x1 = x1(:);
x2 = x2(:);
n = numel(x1);

% shift x2 by mean(x1-x2)
x1 = mod(x1,2*pi);
x2 = mod(x2+angle(mean(exp(1i*(x1-x2)))),2*pi);

% compute shifted correlation coefficients
xd = (1:nd)/nd*2*pi;
rd = nan(1,nd);
for id = 1:nd
    rd(id) = getr(x1+xd(id),x2+xd(id));
end

% return mean correlation coefficient
r = mean(rd);

if nargout > 1
    % compute bootstrap estimate of 95% confidence interval
    r_res = nan(nres,1);
    for ires = 1:nres
        i = randsample(n,n,true);
        for id = 1:nd
            rd(id) = getr(x1(i)+xd(id),x2(i)+xd(id));
        end
        r_res(ires) = mean(rd);
    end
    r_c95 = quantile(r_res,[0.025,0.975]);
end

end

function [r] = getr(x1,x2)
% compute uncorrected circular correlation coefficient
num = sum(sin(x1).*sin(x2));
den = sqrt(sum(sin(x1).^2).*sum(sin(x2).^2));
r = num/den;
end

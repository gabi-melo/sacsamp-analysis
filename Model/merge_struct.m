function [s] = merge_struct(varargin)
%  MERGE_STRUCT  Merge the fields of multiple structures into a single one
%
%  Usage: [s] = merge_struct(s1,s2,s3,...)
%
%  where s1,s2,s3 are the structures whose fields are to be merged
%        s is the merged single structure
%
%  Valentin Wyart <valentin.wyart@inserm.fr>

s = varargin{1};
for i = 2:nargin
    fnam = fieldnames(varargin{i});
    for j = 1:numel(fnam)
        if ~isfield(s,fnam{j})
            s.(fnam{j}) = varargin{i}.(fnam{j});
        end
    end
end

end
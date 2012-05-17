function [pathnames,tsnames] = dir(h)

% Copyright 2005 The MathWorks, Inc.

pathnames = h.TSPathCache;
tsnames = cell(size(pathnames));
for k=1:length(pathnames)
    thisname = pathnames{k};
    ind = strfind(thisname,'/');
    if ~isempty(ind)
        tsnames{k} = thisname(ind(end)+1:end);
    else
        tsnames{k} = thisname;
    end
end
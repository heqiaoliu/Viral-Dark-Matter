function varargout = statsplotfunc(action,fname,inputnames,inputvals)
%STATPLOTFUNC  Support function for Plot Picker component.

% Copyright 2009 The MathWorks, Inc.

% Default display functions for stats plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    switch lower(fname)
        case 'boxplot' % Numeric vector or matrix and optional grouping variable
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ~isscalar(x)&& ndims(x)==2;
            elseif n==2
                x = inputvals{1};
                group = inputvals{2};
                toshow = isnumeric(x) && ~isscalar(x) && ndims(x)==2 && ...
                    localCheckValidGroup(x,group);
            end
        case 'ecdf' % 1 numeric vector
            if n==1
                x = inputvals{1};
                toshow =  isnumeric(x) && ~isscalar(x) && isvector(x);
            end
        case 'histfit'
            if n==1
                x = inputvals{1};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x);
            elseif n==2
                x = inputvals{1};
                n = inputvals{2};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && ...
                    isscalar(n) && n>0 && round(n)==n;
            elseif n==3
                x = inputvals{1};
                n = inputvals{2};
                dist = inputvals{3};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && ...
                    isscalar(n) && n>0 && round(n)==n;
                toshow = toshow && ischar(dist);
            end
        case 'ksdensity'
            if n==1
                x = inputvals{1};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x);
            elseif n==2
                x = inputvals{1};
                xi = inputvals{2};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x);
                toshow = toshow && isvector(xi) && isnumeric(xi) && ~isscalar(xi);
            end
        case 'probplot'
            if n==1
                Y = inputvals{1};
                toshow = isnumeric(Y) && ~isscalar(Y) && ndims(Y)==2;
            elseif n==3
                Y = inputvals{1};
                cens = inputvals{2};
                freq = inputvals{3};
                toshow = isnumeric(Y) && ~isscalar(Y) && ndims(Y)==2 && ...
                    isequal(size(Y),size(cens)) && isequal(size(freq),size(Y));
                toshow = toshow && all((logical(cens(:))-cens(:))==0) && all(freq(:)>=0 && ...
                    (round(freq(:))-freq(:))==0);
            end
        case 'weibull probability plot'
            if n==1
                Y = inputvals{1};
                toshow = isnumeric(Y) && ~isscalar(Y) && ndims(Y)==2 && all(Y(:)>=0);
            elseif n==3
                Y = inputvals{1};
                cens = inputvals{2};
                freq = inputvals{3};
                toshow = isnumeric(Y) && ~isscalar(Y) && ndims(Y)==2 && ...
                    isequal(size(Y),size(cens)) && isequal(size(freq),size(Y)) && ...
                    all(Y(:)>=0);
                toshow = toshow && all((logical(cens(:))-cens(:))==0) && all(freq(:)>=0 && ...
                    (round(freq(:))-freq(:))==0);
            end
        case 'qqplot'
            if n==1
                X = inputvals{1};
                toshow = isnumeric(X) && ~isscalar(X) && ndims(X)==2;
            elseif n==2
                X = inputvals{1};
                Y = inputvals{2};
                toshow = isnumeric(X) && ~isscalar(X) && ndims(X)==2 && ...
                    ((ndims(Y)==2 && ~isscalar(Y) && isnumeric(Y) && ...
                        (isvector(X) || isvector(Y) || size(X,2)==size(Y,2))) || ...
                    isa(Y,'ProbDistUnivParam') || isa(Y,'ProbDistUnivKernel'));
            elseif n==3
                X = inputvals{1};
                Y = inputvals{2};
                pvec = inputvals{3};
                toshow = isnumeric(X) && ~isscalar(X) && ndims(X)==2 && ...
                    (ndims(Y)==2 && ~isscalar(Y) && isnumeric(Y) && ...
                        (isvector(X) || isvector(Y) || size(X,2)==size(Y,2)));
                toshow = toshow && isnumeric(pvec) && ~isscalar(pvec) && ...
                    isvector(pvec);
                toshow = toshow && all(pvec(:)>=0 & pvec(:)<=100); 
            end
        case 'gscatter'
            if n==3
                x = inputvals{1};
                y = inputvals{2};
                group = inputvals{3};
                toshow = isnumeric(x) && isnumeric(y) && isvector(x) && isvector(y) && ...
                    ~isscalar(x) && length(x)==length(y) && localCheckValidGroup(x,group);
            end
        case 'hist3'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)==2;
            elseif n==2
                x = inputvals{1};
                n = inputvals{2};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)==2;
                if ~toshow
                    varargout{1} = toshow;
                    return;
                end
                toshow = isnumeric(n) && isvector(n) && length(n)==2 && ...
                    all(round(n(:))-n(:)==0) && all(n(:)>0);
                if toshow
                    varargout{1} = toshow;
                    return;
                end
                toshow = iscell(n) && isvector(n) && length(n)==2 && isnumeric(n{1}) && ...
                    isnumeric(n{2}) && isvector(n{1}) && isvector(n{2}) && ...
                    all(diff(n{1})>=0) && all(diff(n{2})>=0);
            end
        case 'scatterhist'
            if n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && ~isscalar(x) && isvector(x) && isvector(y) && ...
                    isnumeric(y) && length(x)==length(y);
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                nbins = inputvals{3};
                toshow = isnumeric(x) && ~isscalar(x) && isvector(x) && isvector(y) && ...
                    length(x)==length(y);
                toshow = toshow && isnumeric(nbins) && isvector(nbins) && length(nbins)==2 && ...
                    all(nbins(:)>0) && all(round(nbins(:))-nbins(:)==0);
            end
        case 'gplotmatrix'
            if n==3
                x = inputvals{1};
                y = inputvals{2};
                group = inputvals{3};
                toshow = isnumeric(x) && ~isvector(x) && ~isvector(y) && ndims(x)==2 && ...
                    ndims(y)==2 && size(x,1)==size(y,1);
                toshow = toshow && localCheckValidGroup(x,group);
            end
        case 'parallelcoords'
            if n==1
                X = inputvals{1};
                toshow = isnumeric(X) && ~isvector(X) && ndims(X)==2;
            end
        case 'andrewsplot'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ~isscalar(x) && ndims(x)==2;
            end
        case 'glyphplot'
            if n==1
                X = inputvals{1};
                toshow = isnumeric(X) && ~isscalar(X) && ndims(X)==2;
            end
         case 'faces glyph plot'
            if n==1
                X = inputvals{1};
                toshow = isnumeric(X) && ~isscalar(X) && ndims(X)==2;
            end
        case 'controlchart'
            if n==1
                X = inputvals{1};
                toshow =  (isnumeric(X) && ~isvector(X) && ndims(X)==2) || ...
                    isa(X,'timeseries');
            elseif n==2
                x = inputvals{1};
                group = inputvals{2};
                toshow =  isnumeric(x) && ~isscalar(x) && ndims(x)==2 && ...
                    localCheckValidGroup(x,group);
            end
        case 'dendrogram'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)==3;
            elseif n==2
                x = inputvals{1};
                p = inputvals{2};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)==3 && ...
                    isscalar(p) && p>=0 && round(p)==p;
            end
            
    end
    varargout{1} = toshow;
elseif strcmp(action,'defaultdisplay') 
    dispStr = '';
    switch lower(fname)
        case 'weibull probability plot'
            dispStr =  ['probplot(''weibull'',' inputnames{1} ');figure(gcf)'];
        case 'faces glyph plot'
            dispStr =  ['glyphplot(' inputnames{1} ',''glyph'',''face'');figure(gcf)'];
    end
    varargout{1} = dispStr;
end



function validGroup = localCheckValidGroup(x,group)

if iscell(group)
    % If this is a valid single group then test it
    if (isvector(x) && isvector(group) && length(group)==size(x,1)) || ...
       (~isvector(x) && isvector(group) && length(group)==size(x,2))
        validGroup = true;
        return;
    % Otherwise, maybe group is a cell array of groups. If any are invalid 
    % then return false.
    else
        for k=1:numel(group)
            if ~localCheckValidGroup(group{k})
               validGroup = false;
               return;
            end
        end
        validGroup = true;
        return
    end
end

% Check validity of numeric and char array groups
if ischar(group)
    validGroup = (~isvector(x) && size(group,1)==size(x,2)) || ...
        (isvector(x) && size(group,1)==size(x,1));
else
    validGroup = (isvector(x) && isvector(group) && length(group)==size(x,1)) || ...
           (~isvector(x) && isvector(group) && length(group)==size(x,2));
end

function [NumSamples, NumSeries, NumParams, Y, X, goodrows] = ...
    statcheckmvnr(Y, X, Param, Covar, IgnoreNaNs)
%STATCHECKMVNR Argument checking function for mvregress.

%    Copyright 2006 The MathWorks, Inc.
%    $Revision: 1.1.8.1 $ $Date: 2010/03/16 00:30:05 $

if nargin < 5
    IgnoreNaNs = false;
end
if nargin < 4
    Covar = [];
end
if nargin < 3
    Param = [];
end
if (nargin < 2)
    error('stats:statcheckmvnr:MissingInputArg', ...
        'Missing required arguments Y or X.');
end

[NumSamples, NumSeries] = size(Y);

if iscell(X)
    X = X(:);
    [m, n] = size(X);

    if m == 1
        SingleX = true;
    elseif m == NumSamples
        SingleX = false;
    else
        error('stats:statcheckmvnr:InconsistentDims', ...
            'Invalid number of cell array elements - should be either NumSamples or 1.');
    end

    if n > 1
        error('stats:statcheckmvnr:InvalidDesignArray', ...
            'X cell array must be either a NumSamples x 1, 1 x NumSamples, or 1 x 1 cell array.');
    end

    if isempty(X{1})
        error('stats:statcheckmvnr:InvalidDesignArray', ...
            'Empty X{1} cell array element - unable to continue.');
    end

    [n, NumParams] = size(X{1});

    if n ~= NumSeries
        error('stats:statcheckmvnr:InconsistentDims', ...
            'Invalid number of series in cell array elements (should be NumSeries).');
    end

    if ~SingleX
        for k = 1:NumSamples
            if isempty(X{k})
                error('stats:statcheckmvnr:InvalidDesignArray', ...
                    'Empty X{%d} cell array element.',k);
            end
            if ~all(isequal(size(X{k}), [NumSeries, NumParams]))
                error('stats:statcheckmvnr:InconsistentDims', ...
                    'Invalid dimensions for X{%d} cell array element (should be NumSeries x NumSamples).',k);
            end
        end
    end
else
    [n, NumParams] = size(X);

    if n ~= NumSamples
        error('stats:statcheckmvnr:InconsistentDims', ...
            'Invalid format or dimensions for X matrix (should be NumSamples x NumParams).');
    end
end

if any(sum(isnan(Y),1) == NumSamples)
    error('stats:statcheckmvnr:TooManyNaNs', ...
        'One or more data series has all NaNs.');
end

if any(any(isinf(Y)))
    error('stats:statcheckmvnr:InfiniteValue', ...
        'One or more infinite values found in Y.');
end

if iscell(X)
    if SingleX
        if any(any(isnan(X{1})))
            error('stats:statcheckmvnr:InvalidDesign', ...
                'Cell array with single X{1} matrix cannot have missing values.');
        end

        if any(any(isinf(X{1})))
            error('stats:statcheckmvnr:InfiniteValue', ...
                'One or more infinite values found in cell array with single X{1} matrix.');
        end

        r = rank(X{1});
        if (NumSeries < NumParams) || (r ~= NumParams)
            error('stats:statcheckmvnr:InvalidDesignArray', ...
                'Cell array with single X{1} matrix has rank-deficient matrix.');
        end
    else
        for k = 1:NumSamples
            if any(any(isinf(X{k})))
                error('stats:statcheckmvnr:InfiniteValue', ...
                    'One or more infinite values found in cell array X(%d) matrix.',k);
            end
        end
    end
else
    if any(any(isinf(X)))
        error('stats:statcheckmvnr:InfiniteValue', ...
              'One or more infinite values found in X matrix.');
    end
end

if ~isempty(Param) && ~all(isequal(size(Param), [NumParams, 1]))
    error('stats:statcheckmvnr:InconsistentDims', ...
        'Invalid dimensions for model parameter vector (should be %d x 1).',NumParams);
end

if ~isempty(Covar) && ~all(isequal(size(Covar), [NumSeries, NumSeries]))
    error('stats:statcheckmvnr:InconsistentDims', ...
        'Invalid dimensions for covariance or weight matrix (should be %d x %d).', ...
        NumSeries, NumSeries);
end

% Remove rows with too many NaNs
if IgnoreNaNs
    goody = ~any(isnan(Y),2);
else
    goody = ~all(isnan(Y),2);
end
if ~iscell(X)
    goodx = ~any(isnan(X),2);
elseif ~isscalar(X)
    X = X(:);
    goodx = goody;
    for j=1:numel(X)
        if any(any(isnan(X{j})))
            goodx(j) = false;
        end
    end
else
    goodx = true;  % scalar cell case was checked earlier
end

if ~any(goodx)
    error('stats:statcheckmvnr:InvalidDesign', ...
          'Too many missing values in X matrix.');
end

goodrows = goody & goodx;
if ~all(goodrows)
    Y = Y(goodrows,:);
    NumSamples = size(Y,1);
    if ~isscalar(X)
        X = X(goodrows,:);
    end
end

function [no,xo] = hist(Y,X)
%Embedded MATLAB Library Function

%   Limitations:
%     1. Histogram bar plotting is not supported: must be called with at
%        least one output argument.
%     2. If the second argument X is supplied and is a scalar, it must be a
%        constant.
%     3. Inputs must be real.

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargout > 0, ...
    'Not enough output arguments. Histogram bar plot is not supported.');
if eml_is_const(isvector(Y)) && isvector(Y)
    y = Y(:);
    y_isa_vector = true;
else
    eml_lib_assert(isscalar(Y) || ~isvector(Y) || size(Y,1) ~= 1, ...
        'EmbeddedMATLAB:hist:vsizeMatrixBecameRowVec', ...
        'A variable-size input matrix or N-D array must not become a row vector at runtime.');
    y = Y;
    y_isa_vector = false;
end
if nargin == 1
    X = 10;
else
    eml_assert(eml_is_const(isvector(X)), ...
    ['X must be a fixed-size scalar or a vector. If X is a vector, ', ...
    'it can have at most one variable-length dimension, the first ', ...
    'dimension or the second. All other dimensions must have a fixed ', ...
    'length of 1.']);
    eml_assert(isvector(X), 'X must be a scalar or a vector.');
end
eml_assert( ...
    (isa(X,'float') || islogical(X)) && ...
    (isa(Y,'float') || islogical(Y)), ... , ...
    'Input arguments must be ''double'', ''single'', or ''logical''.');
eml_assert(isreal(Y) && isreal(X), 'Inputs must be real.');
if islogical(y)
    % The only non-float case that actually works in MATLAB.
    eml_prefer_const(X);
    [no,xo] = hist(double(y),X);
elseif eml_is_const(isscalar(X)) && isscalar(X)
    eml_prefer_const(X);
    eml_assert(eml_is_const(X), 'Scalar X must be constant.');
    if isempty(y)
        xp0y = X + eml_scalar_eg(y);
        if y_isa_vector
            xo = 1:xp0y;
            no = zeros(eml_numel(xo),1);
        else
            xo = (1:xp0y).';
            no = zeros(1,eml_numel(xo));
        end
        return
    end
    [miny,maxy] = MinAndMaxNoNaNs(y);
    if miny == maxy
        miny(1) = miny - floor(X/2) - 0.5;
        maxy(1) = maxy + ceil(X/2) - 0.5;
    end
    binwidth = (maxy - miny) ./ X;
    % Match HIST behavior in MATLAB.
    if y_isa_vector
        xo = miny + binwidth*(0:X-1);
        % Shift bins so the interval is ( ] instead of [ ).
        edges = [-eml_guarded_inf,xo,maxy];
    else
        xo = miny + binwidth*(0:X-1).';
        % Shift bins so the interval is ( ] instead of [ ).
        edges = [-eml_guarded_inf;xo;maxy];
    end
    for k = 2:eml_numel(edges)
        edges(k) = edges(k) + eps(edges(k));
    end
    nn = histc(y,edges,1);
    no = trimCounts(nn);
    xo = xo + binwidth/2;
else
    eml_lib_assert(~isscalar(X), ...
        'EmbeddedMATLAB:hist:variableSizeScalarX', ...
        ['If X is a variable-length vector, it must not have length 1: ', ...
        'scalar X must be fixed-size.']);
    if isempty(y)
        if y_isa_vector
            xo = X;
            no = zeros(eml_numel(xo),1);
        else
            xo = X(:);
            no = zeros(1,eml_numel(xo));
        end
        return
    end
    % Match HIST vector orientation in MATLAB.
    if y_isa_vector && eml_is_const(size(X,1)) && size(X,1) == 1
        xo = X(:).';
    else
        xo = X(:);
    end
    nx = eml_numel(xo);
    if isa(xo,'float')
        edges = eml.nullcopy(eml_expand(eml_scalar_eg(xo),[1,nx+2]));
    else
        edges = eml.nullcopy(zeros(1,nx+2));
    end
    edges(1) = -eml_guarded_inf;
    edges(2) = xo(1) - (xo(2) - xo(1))/2;
    for k = 1:nx-1
        edges(k+2) = xo(k) + (xo(k+1) - xo(k))/2;
    end
    edges(nx+2) = xo(end);
    [miny,maxy] = MinAndMaxNoNaNs(y);
    if edges(2) > miny
        edges(2) = miny;
    end
    if edges(end) < maxy
        edges(end) = maxy;
    end
    % Shift bins so the interval is ( ] instead of [ ).
    for k = 2:nx+2
        edges(k) = edges(k) + eps(edges(k));
    end
    nn = histc(y,edges,1);
    no = trimCounts(nn);
end

%--------------------------------------------------------------------------

function [miny,maxy] = MinAndMaxNoNaNs(y)
% Ignore NaN when computing miny and maxy.  Do not call this routine if y
% is empty.
ny = eml_numel(y);
k = 1;
while k <= ny
    if ~isnan(y(k))
        break
    end
    k = k + 1;
end
if k > ny
    % All NaNs.
    miny = y(1);
    maxy = y(1);
else
    miny = y(k);
    maxy = y(k);
    while k <= ny
        if y(k) < miny
            miny = y(k);
        end
        if y(k) > maxy
            maxy = y(k);
        end
        k = k + 1;
    end
end

%--------------------------------------------------------------------------

function no = trimCounts(nn)
% Combine first bin with 2nd bin and last bin with next to last bin.
if eml_is_const(isvector(nn)) && isvector(nn)
    % Return a row vector.
    no = nn(2:end-1).';
    no(1) = no(1) + nn(1);
    no(end) = no(end) + nn(end);
else
    no = nn(2:end-1,:);
    if ~isempty(no)
        for k = 1:size(no,2)
            no(1,k) = no(1,k) + nn(1,k);
            no(end,k) = no(end,k) + nn(end,k);
        end
    end
end

%--------------------------------------------------------------------------

function y = norm(x,p)
%Embedded MATLAB Library Function

%   Limitations:
%       If NaN is present in X, the result is NaN.

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(x,'float'), ...
    ['Operation ''norm'' is not defined for values of class ''' class(x) '''.']);
eml_lib_assert(ndims(x) <= 2, 'EmbeddedMATLAB:norm:inputMustBe2D', ...
    'Input x must be a vector or 2-D matrix.');
eml_assert(nargin == 1 || ((isscalar(p) && isa(p,'numeric')) || ischar(p)), ...
    'The only matrix norms available are 1, 2, inf, and ''fro''.');
if nargin < 2
    p = 2;
elseif ~((ischar(p) && (strcmp(p,'fro') || strcmp(p,'inf'))) || ...
        (isa(p,'numeric') && (isvector(x) || p == 1 || p == 2 || ...
        (isa(p,'float') && p > 0 && eml_isinf(p)))))
    eml_error('MATLAB:norm:unknownNorm', ...
        'The only matrix norms available are 1, 2, inf, and ''fro''.');
    y = eml_guarded_nan(class(x));
    return
end
eml_prefer_const(p);
if eml_is_const(size(x)) && isempty(x)
    y = zeros(class(x));
elseif eml_is_const(size(x)) && isscalar(x)
    if ischar(p) || p ~= 0
        y = abs(x);
    else
        y = eml_guarded_nan(class(x));
    end
elseif isvector(x)
    y = genpnorm(x,p);
elseif ischar(p) && strcmp(p,'fro')
    y = eml_xnrm2(eml_numel(x),x,1,1);
elseif ischar(p) || (isa(p,'float') && p > 0 && eml_isinf(p))
    y = matinfnorm(x);
elseif p == 1
    y = mat1norm(x);
elseif p == 2
    s = svd(x);
    y = s(1);
else
    y = eml_guarded_nan(class(x));
end

%--------------------------------------------------------------------------

function y = mat1norm(x)
% max(sum(abs(x)))
m = size(x,1);
n = size(x,2);
ZERO = zeros(class(x));
y = ZERO;
for j = 1:n
    s = ZERO;
    for i = 1:m
        s = s + abs(x(i,j));
    end
    if isnan(s)
        y = eml_guarded_nan(class(x));
        return
    elseif s > y
        y = s;
    end
end

%--------------------------------------------------------------------------

function y = matinfnorm(x)
% max(sum(abs(x')))
% Same as mat1norm(x') but without creating a temporary for x'.
m = size(x,1);
n = size(x,2);
ZERO = zeros(class(x));
y = ZERO;
for i = 1:m
    s = ZERO;
    for j = 1:n
        s = s + abs(x(i,j));
    end
    if isnan(s)
        y = eml_guarded_nan(class(x));
        return
    elseif s > y
        y = s;
    end
end

%--------------------------------------------------------------------------

function y = vecpospnorm(x,p)
% Vector p-norm for finite p > 0.
eml_prefer_const(p);
n = eml_numel(x);
y = zeros(class(x));
scale = zeros(class(x));
for k = 1:n
    absx = abs(x(k));
    if isnan(absx)
        y = eml_guarded_nan(class(x));
        return
    elseif isinf(absx)
        y = eml_guarded_inf(class(x));
        for j = k+1:n
            if isnan(x(j))
                y = eml_guarded_nan(class(x));
                return
            end
        end
        return
    elseif absx > 0
        if scale < absx
            y = 1 + y*eml_rdivide(scale,absx).^p;
            scale = absx;
        else
            y = y + eml_rdivide(absx,scale).^p;
        end
    end
end
if y > 0 && ~isinf(y)
    y = scale * y.^eml_rdivide(1,p);
end

%--------------------------------------------------------------------------

function y = vecnegpnorm(x,p)
% Vector p-norm for finite p < 0.
eml_prefer_const(p);
n = eml_numel(x);
y = zeros(class(x));
scale = eml_guarded_inf(class(x));
for k = 1:n
    absx = abs(x(k));
    if isnan(absx)
        y = eml_guarded_nan(class(x));
        return
    elseif absx == 0
        y = zeros(class(x));
        for j = k+1:n
            if isnan(x(j))
                y = eml_guarded_nan(class(x));
                return
            end
        end
        return
    elseif absx < scale
        y = 1 + y*eml_rdivide(scale,absx).^p;
        scale = absx;
    elseif ~isinf(absx)
        y = y + eml_rdivide(absx,scale).^p;
    end
end
if y > 0 && ~isinf(y)
    y = scale * y^eml_rdivide(1,p);
end

%--------------------------------------------------------------------------

function y = genpnorm(x,p)
% Vector p-norm with special cases for various p.
% Assumes that if ischar(p), p = 'fro' or p = 'inf'.
eml_prefer_const(p);
ONE = ones(eml_index_class);
if (ischar(p) && strcmp(p,'fro')) || (isa(p,'numeric') && p == 2)
    y = eml_xnrm2(eml_numel(x),x,ONE,ONE);
elseif ischar(p) || (isa(p,'float') && p > 0 && eml_isinf(p))
    % y = max(abs(x(:))) except nans are not ignored.
    y = zeros(class(x));
    for k = 1:eml_numel(x)
        absx = abs(x(k));
        if isnan(absx)
            y = eml_guarded_nan(class(x));
            break
        elseif absx > y
            y = absx;
        end
    end
elseif p == 1
    % y = sum(abs(x(:)));
    y = zeros(class(x));
    for k = 1:eml_numel(x)
        y = y + abs(x(k));
    end
elseif isa(p,'float') && p < 0 && eml_isinf(p)
    % y = min(abs(x(:))) except that nans are not ignored.
    y = eml_guarded_inf(class(x));
    for k = 1:eml_numel(x)
        absx = abs(x(k));
        if isnan(absx)
            y = eml_guarded_nan(class(x));
            break
        elseif absx < y
            y = absx;
        end
    end
elseif p > 0
    y = vecpospnorm(x,cast(p,class(x)));
elseif p < 0
    y = vecnegpnorm(x,cast(p,class(x)));
elseif p == 0
    y = eml_guarded_inf(class(x));
else
    y = eml_guarded_nan(class(x));
end

%--------------------------------------------------------------------------

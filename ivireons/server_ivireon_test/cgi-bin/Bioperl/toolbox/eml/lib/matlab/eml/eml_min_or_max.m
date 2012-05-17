function [extremum,indx] = eml_min_or_max(modestr,x,y,dim)
%Embedded MATLAB Private Function

%   MIN or MAX function with modestr == 'min' or modestr == 'max',
%   respectively.  Intended to work with arbitrary input types as long as
%   ISNAN and the relational operators LT (for 'min') and GT (for 'max')
%   are defined.  Additionally, for complex inputs, EML_SCALAR_ABS and ...
%   EML_SCALAR_ANGLE are needed.

%   Copyright 2003-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(ischar(modestr) && ...
    (strcmp(modestr,'max') || strcmp(modestr,'min')), ...
    'First argument must be ''min'' or ''max''.');
eml_assert(isnumeric(x) || ischar(x) || islogical(x), ...
    ['Function ''' modestr ''' is not defined for values of class ''' ...
    class(x) '''.']);
eml_assert(isreal(x) || ~isinteger(x), ...
    ['Complex integer ''' modestr ''' is not supported']);
domax = eml_const(strcmp(modestr,'max'));
if nargin == 2
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:eml_min_or_max:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
elseif nargin == 3
    eml_assert(nargout <= 1, ['Function ''' modestr ''' with two ', ...
        'matrices to compare and two output arguments is not supported.']);
    eml_assert(isnumeric(y) || ischar(y) || islogical(y), ...
        ['Function ''' modestr ''' is not defined for values of class ''' ...
        class(y) '''.']);
    eml_assert(isreal(y) || ~isinteger(y), ['Complex integer ''' ...
        modestr ''' is not supported']);
    eml_assert(isa(x,class(y)) || ...
        (isscalar(y) && isa(y,'double')) || ... % Scalar doubles combine with anything.
        (isscalar(x) && isa(x,'double')) || ...
        ((~isinteger(x) && (isfloat(x) || islogical(x) || ischar(y))) && ...
        (~isinteger(y) && (isfloat(y) || islogical(y) || ischar(y)))), ...
        ['Mixed inputs must either be single and double, or integer ', ...
        'and scalar double. All other combinations are no longer allowed.']);
    extremum = eml_bin_extremum(domax,x,y);
    return
else
    eml_assert(isempty(y), ['Function ''' modestr ''' with two ', ...
        'matrices to compare and a working dimension is not supported.']);
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim), 'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
if eml_is_const(size(x,dim)) && size(x,dim) <= 1
    outsz = size(x);
else
    eml_lib_assert(size(x,dim) > 0, ...
        'EmbeddedMATLAB:eml_min_or_max:varDimZero', ...
        ['If the working dimension of MAX or MIN is variable in ', ...
        'length, it must not have zero length at runtime.']);
    outsz = size(x);
    outsz(dim) = 1;
end
if ischar(x)
    eZERO = 0;
else
    eZERO = eml_scalar_eg(x);
end
extremum = eml.nullcopy(eml_expand(eZERO,outsz));
indx = ones(size(extremum));
n = cast(size(x,dim),eml_index_class);
if eml_is_const(isempty(extremum)) && isempty(extremum)
elseif eml_is_const(isscalar(extremum)) && isscalar(extremum)
    [mtmp,itmp] = eml_extremum_sub(domax,x);
    extremum(1) = mtmp;
    indx(1) = itmp;
else
    vstride = eml_matrix_vstride(x,dim);
    vspread = eml_index_times(eml_index_minus(n,1),vstride);
    npages = eml_matrix_npages(x,dim);
    ix = zeros(eml_index_class);
    iy = zeros(eml_index_class);
    for i = 1:npages
        for j = 1:vstride
            ix = eml_index_plus(ix,1);
            [mtmp,itmp] = eml_extremum_sub(domax,x,ix,vstride,n);
            iy = eml_index_plus(iy,1);
            extremum(iy) = mtmp;
            indx(iy) = itmp;
        end
        ix = eml_index_plus(ix,vspread);
    end
end

%--------------------------------------------------------------------------

function extremum = eml_bin_extremum(domax,x,y)
% Min or max values selected from two inputs, x and y.
% The input DOMAX is logical, true for max, false for min.
if islogical(x) && islogical(y)
    extremum = eml_scalexp_alloc(false,x,y);
else
    extremum = eml_scalexp_alloc(eml_scalar_eg(x,y),x,y);
end
ONE = ones(eml_index_class);
if isreal(x) && isreal(y)
    for k = ONE:eml_numel(extremum);
        xk = eml_scalexp_subsref(x,k);
        yk = eml_scalexp_subsref(y,k);
        extremum(k) = eml_scalar_bin_extremum(domax,xk,yk,xk,yk);
    end
else
    % We eschew the eml_scalexp_subsref approach below to avoid repeated
    % calculation of the absolute value of a scalar argument.
    if eml_is_const(size(x)) && isscalar(x)
        absx = eml_scalar_abs(x);
        for k = ONE:eml_numel(extremum)
            extremum(k) = eml_scalar_bin_extremum(domax,x,y(k),absx, ...
                eml_scalar_abs(y(k)));
        end
    elseif eml_is_const(size(y)) && isscalar(y)
        absy = abs(y);
        for k = ONE:eml_numel(extremum)
            extremum(k) = eml_scalar_bin_extremum(domax,x(k),y, ...
                eml_scalar_abs(x(k)),absy);
        end
    else
        for k = ONE:eml_numel(extremum)
            extremum(k) = eml_scalar_bin_extremum(domax,x(k),y(k), ...
                eml_scalar_abs(x(k)),eml_scalar_abs(y(k)));
        end
    end
end

%--------------------------------------------------------------------------

function extremum = eml_scalar_bin_extremum(domax,x,y,rx,ry)
% Min or max of scalars x and y using the associated real values rx and ry
% for the primary comparison.  The values rx and ry should have the
% property isnan(rx) == isnan(x) and isnan(ry) == isnan(y).
% The input DOMAX is logical, true for max, false for min.
eml_must_inline;
extremum = eml.nullcopy(eml_scalar_eg(x,y)); % Handle mixed class and complexness.
codingForHDL = eml_const(strcmp(eml.target(),'hdl'));
if eml_const(domax)
    if isreal(x) && isreal(y)
        if ~codingForHDL && ~eml_option('DesignVerifier') && ...
                isa(x,class(y)) && isa(x,'numeric')
            extremum(1) = eml_max(x,y);
        else
            if rx < ry || isnan(rx)
                extremum(1) = y;
            else
                extremum(1) = x;
            end
        end
    else
        if rx > ry
            extremum(1) = x;
        elseif ry > rx || isnan(rx)
            extremum(1) = y;
        elseif eml_scalar_angle(y) > eml_scalar_angle(x) % Complex tiebreaker.
            extremum(1) = y;
        else
            extremum(1) = x;
        end
    end
else
    if isreal(x) && isreal(y)
        if ~codingForHDL && ~eml_option('DesignVerifier') && ...
                isa(x,class(y)) && isa(x,'numeric')
            extremum(1) = eml_min(x,y);
        else
            if rx > ry || isnan(rx)
                extremum(1) = y;
            else
                extremum(1) = x;
            end
        end
    else
        if rx < ry
            extremum(1) = x;
        elseif ry < rx || isnan(rx)
            extremum(1) = y;
        elseif eml_scalar_angle(y) < eml_scalar_angle(x) % Complex tiebreaker.
            extremum(1) = y;
        else
            extremum(1) = x;
        end
    end
end

%--------------------------------------------------------------------------

function [extremum,indx] = eml_extremum_sub(domax,x,ixstart,stride,n)
% Computes the max or min of the vector
%     v = X(IXSTART:STRIDE:IXSTART+(N-1)*STRIDE).
% INDX will be an integer between 1 and N.  It is the index of the
% extremum in the vector v (i.e., not the index of the extremum in the
% array X).  The input DOMAX is logical, true for max, false for min.
% If nargin < 5, ixstart = 1, stride = 1, and n = eml_numel(x).
eml_must_inline;
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
if nargin < 5
    ixstart = ONE;
    stride = ONE;
    n = cast(eml_numel(x),eml_index_class);
end
extremum = x(ixstart);
indx = ONE;
if n == 1
    return
end
ix = ixstart;
codingForHDL = eml_const(strcmp(eml.target(),'hdl'));
if isnan(extremum)
    searchingForNonNaN = true;
    if codingForHDL
        ixk = ixstart;
    end
    % Avoid short circuiting the loop.
    % Find the first non-NaN, if any.
    for k = TWO:n
        ix = eml_index_plus(ix,stride);
        if searchingForNonNaN && ~isnan(x(ix))
            extremum = x(ix);
            indx = k;
            searchingForNonNaN = false;
            if codingForHDL
                ixk = indx;
            else
                break
            end
        end
    end
    if codingForHDL
        ix = ixk;
    end
    if searchingForNonNaN
        % All NaNs, all done.
        return
    end
end
if isreal(x)
    for k = eml_index_plus(indx,1):n
        ix = eml_index_plus(ix,stride);
        if eml_const(domax)
            if x(ix) > extremum
                extremum = x(ix);
                indx = k;
            end
        else
            if x(ix) < extremum
                extremum = x(ix);
                indx = k;
            end
        end
    end
else
    absextremum = eml_scalar_abs(extremum);
    for k = eml_index_plus(indx,1):n
        ix = eml_index_plus(ix,stride);
        absxk = abs(x(ix));
        if eml_const(domax)
            if absxk > absextremum || ...
                    (absxk == absextremum && ...
                    eml_scalar_angle(x(ix)) > eml_scalar_angle(extremum))
                extremum = x(ix);
                absextremum = absxk;
                indx = k;
            end
        else
            if absxk < absextremum || ...
                    (absxk == absextremum && ...
                    eml_scalar_angle(x(ix)) < eml_scalar_angle(extremum))
                extremum = x(ix);
                absextremum = absxk;
                indx = k;
            end
        end
    end
end

%--------------------------------------------------------------------------

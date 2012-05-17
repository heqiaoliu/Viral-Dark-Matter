function x = detrend(x,o,bp)
%Embedded MATLAB Library Function

%   Limitations:
%       This implementation does not adjust the BP input before using it
%       as the MATLAB implementation does.  If the third argument BP is
%       supplied and non-empty, it must already satisfy the following
%       requirements.
%       1.  BP must be real.
%       2.  BP must be sorted in ascending order.
%       3.  BP must have all integer elements in the interval [1,n-2],
%           where n is the number of elements in a column of X (or the
%           number of elements in X when X is a row vector).
%       4.  BP must contain all unique values.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(isa(x,'float'), ...
    ['Function ''detrend'' is not defined for values of class ''' ...
    class(x) '''.']);
eml_lib_assert(ndims(x) == 2, ...
    'EmbeddedMATLAB:detrend:inputsMustBe2D', ...
    'Input arguments must be 2-D.');
% Supply default values for o and bp if necessary.
if nargin < 3
    bp = [];
    if nargin < 2
        o = 1;
    end
end
[nrows,ncols] = size(x);
eml_prefer_const(o);
if ischar(o)
    % Force o == 0 or o == 1 using a single recursive call.
    if strcmp(o,'c') || strcmp(o,'constant')
        x = detrend(x,0,bp);
    elseif strcmp(o,'l') || strcmp(o,'linear')
        x = detrend(x,1,bp);
    end
elseif ~(isa(o,'numeric') && (o == 0 || o == 1))
    eml_error('MATLAB:detrend:InvalidTrendType','Invalid trend type.');
elseif eml_is_const(isempty(x)) && isempty(x)
    % Do nothing.
elseif (eml_is_const(size(x)) && isvector(x) && ncols > 1) || ( ...
        eml_is_const(isvector(x)) && isvector(x) && ...
        eml_is_const(size(x,1)) && size(x,1) == 1 && ...
        ~eml_is_const(size(x,2))) % Exclude fixed-size scalar x.
    % Handle row vector special case.
    x = detrend(x.',o,bp).';
else
    eml_lib_assert(eml_is_const(isvector(x)) || ~isvector(x) || ...
        nrows >= ncols, ...
        'EmbeddedMATLAB:detrend:rowVecSpecialCase', ...
        ['The input was a variable-size matrix that became a row ', ...
        'vector at runtime. Use a variable-length row vector instead.']);
    ONE = ones(eml_index_class);
    TWO = cast(2,eml_index_class);
    if o == 0
        % Remove just mean from each column
        for k = ONE:ncols
            xbar = eml_scalar_eg(x);
            for j = ONE:nrows
                xbar = xbar + x(j,k);
            end
            xbar = eml_div(xbar,nrows);
            for j = ONE:nrows
                x(j,k) = x(j,k) - xbar;
            end
        end
    else
        if nargin < 3 || isempty(bp)
            nca = 2;
        else
            check_bp(bp,nrows);
            nca = eml_numel(bp) + 2;
        end
        % Build regressor with linear pieces + DC
        a = eml.nullcopy(eml_expand(eml_scalar_eg(real(x)),[nrows,nca]));
        N = cast(nrows,class(x));
        for i = ONE:nrows
            a(i,1) = eml_rdivide(cast(i,class(x)),N);
            a(i,nca) = 1;
        end
        for j = TWO:nca-1
            k = eml_index_minus(j,ONE);
            bpk = cast(bp(k),class(x));
            ibpk = cast(bp(k),eml_index_class);
            M = N - bpk;
            for i = ONE:ibpk
                a(i,j) = 0;
            end
            for i = eml_index_plus(ibpk,ONE):nrows
                a(i,j) = eml_rdivide(cast(i,class(x))-bpk,M);
            end
        end
        x = x - a*(a\x); % Remove best fit.
        % Instead of the preceding line, the following should work for
        % N-D inputs when MATLAB allows N-D inputs to this function.
        %     if ndims(x) > 2
        %         d = a*(a\reshape(x,[nrows,ncols]));
        %     else
        %         d = a*(a\x);
        %     end
        %     for k = ONE:numel(x)
        %         x(k) = x(k) - d(k);
        %     end
    end
end

%--------------------------------------------------------------------------

function check_bp(bp,nrows)
eml_assert(isreal(bp) && isa(bp,'numeric'), ...
    'The BP vector must be real and numeric.');
nrowsm2 = nrows - 2;
for k = 1:eml_numel(bp)-1
    bpk = bp(k);
    if floor(bpk) ~= bpk
        eml_error('MATLAB:detrend:BPnonfinite', ...
            'The BP vector must contain only integer values.');
    elseif bpk == bp(k+1)
        eml_error('MATLAB:detrend:BPnonunique', ...
            'All elements of the BP vector must be unique.');
    elseif bpk > bp(k+1)
        eml_error('MATLAB:detrend:BPnotsorted', ...
            'The BP vector must be sorted in ascending order.');
    elseif bpk < 1 || bpk > nrowsm2
        eml_error('MATLAB:detrend:BPoutofrange', ...
            ['The BP vector must contain values in the interval ', ...
            '[1,N-2] for data of length N.']);
    end
end

%--------------------------------------------------------------------------

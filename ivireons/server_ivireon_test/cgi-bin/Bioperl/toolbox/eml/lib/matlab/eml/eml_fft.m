function y = eml_fft(op,x,n,dim)
%Embedded MATLAB Private Function

%   FFT and IFFT transforms.
%   Requires that the length of the transformed dimension be a power of 2.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_assert(isa(x,'float'),['Function ''eml_fft'' is not defined for ', ...
    'values of class ''' class(x) '''.']);
eml_assert(ischar(op) && (strcmp(op,'fft') || strcmp(op,'ifft')), ...
    'Unrecognized operation.');
isInverse = strcmp(op,'ifft');
% Compute or validate optional parameters n and dim.
if nargin < 4
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        (isscalar(x) && dim == 2) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:eml_fft:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_assert(eml_is_const(dim), 'DIM must be a constant.');
    eml_assert_valid_dim(dim);
end
if nargin < 3 || isempty(n)
    n1 = cast(size(x,dim),eml_index_class);
    eml_lib_assert(eml_size_ispow2(n1), ...
        'EmbeddedMATLAB:eml_fft:sizeMustBePower2', ...
        'Length of transform dimension must be a power of 2.');
else
    eml_prefer_const(n);
    eml_lib_assert(isscalar(n) && isreal(n) && isa(n,'numeric') && ...
        eml_size_ispow2(n), ...
        'EmbeddedMATLAB:eml_fft:sizeMustBePower2', ...
        'Length of transform dimension must be a power of 2.');
    n1 = cast(n,eml_index_class);
end
if dim > 1
    p = eml_dim_to_fore_permutation(max(dim,eml_ndims(x)),dim);
    % Recurse with the permuted input and dim == 1.
    y1 = eml_fft(op,permute(x,p),n1,1);
    % Apply the inverse permutation to y1 to obtain y.
    y = ipermute(y1,p);
    return
end
y = r2br_r2dit_trig(x,n1,isInverse);

%--------------------------------------------------------------------------

function y = r2br_r2dit_trig(x,nRows,isInverse)
% Bit-reverse and then do in-place radix-2 decimation-in-time FFT
% Trig-based twiddle computation.
% Pad or clip dimension 1 of input x to be nRows long.
eml_must_inline;
% Select twiddle option:
NO_TWIDDLE_TABLE = 0;
SMALL_TWIDDLE_TABLE = 1;
FULL_TWIDDLE_TABLE = 2;
twidopt = FULL_TWIDDLE_TABLE;
% Preallocate output.
sz = size(x);
sz(1) = nRows;
y = eml.nullcopy(eml_expand(eml_scalar_eg(complex(real(x))),sz));
if nRows > size(x,1)
    y(:) = 0;
end
if isempty(x)
    return
end
% Define constants.
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
unRows = eml_cast(nRows,ucls,'wrap');
nRowsM1 = eml_index_minus(min(size(x,1),nRows),1);
ixDelta = max(ONE,eml_index_minus(size(x,1),nRowsM1));
nRowsM2 = eml_index_minus(nRows,TWO);
nRowsD2 = rshift(nRows);
nRowsD4 = rshift(nRowsD2);
nChans = eml_index_rdivide(eml_numel(x),size(x,1));
lastChan = eml_index_times(nRows,eml_index_minus(nChans,1));
e = 2*pi/cast(nRows,class(x));
% Generate twiddle table if desired.
if eml_const(twidopt ~= NO_TWIDDLE_TABLE)
    costab1q = make_1q_cosine_table(e,nRowsD4);
    if eml_const(twidopt == FULL_TWIDDLE_TABLE)
        [costab,sintab] = make_twiddle_table(costab1q,isInverse);
    end
end
% Compute transform one channel at a time.
ix = ZERO;
for chanStart = ZERO:nRows:lastChan
    % Initialize column of y with bitreversed complex copy of the
    % corresponding column of x.
    ju = zeros(ucls);
    iy = chanStart;
    for i = ONE:nRowsM1
        y(eml_index_plus(iy,1)) = x(eml_index_plus(ix,1));
        ju = eml_fft_bitrevidx(ju,unRows);
        iy = eml_index_plus(chanStart,eml_cast(ju,eml_index_class,'wrap'));
        ix = eml_index_plus(ix,1);
    end
    y(eml_index_plus(iy,1)) = x(eml_index_plus(ix,1));
    % Move ix index to the top of the next column of x.
    ix = eml_index_plus(ix,ixDelta);
    % In-place radix-2 decimation-in-time FFT.
    i1 = chanStart;
    i2 = eml_index_plus(i1,nRowsM2);
    if nRows > 1 % See G313314
        for i = i1:TWO:i2
            temp = y(eml_index_plus(i,2));
            y(eml_index_plus(i,2)) = y(eml_index_plus(i,1)) - temp;
            y(eml_index_plus(i,1)) = y(eml_index_plus(i,1)) + temp;
        end
    end
    iDelta = TWO;
    iDelta2 = eml_index_times(iDelta,2);
    k = nRowsD4;
    iheight = eml_index_plus(1,eml_index_times(eml_index_minus(k,1),iDelta2));
    while k > 0
        istart = chanStart;
        j = ZERO;
        % Perform the first butterfly of this stage.  Since twid = 1+0i, no
        % multiplication is required.
        i = istart;
        ihi = eml_index_plus(i,iheight);
        while i < ihi
            temp = y(eml_index_plus(eml_index_plus(i,iDelta),1));
            y(eml_index_plus(eml_index_plus(i,iDelta),1)) = ...
                y(eml_index_plus(i,1)) - temp;
            y(eml_index_plus(i,1)) = y(eml_index_plus(i,1)) + temp;
            i = eml_index_plus(i,iDelta2);
        end
        % Perform the remaining butterflies of this stage.  
        istart = eml_index_plus(istart,1);
        j = eml_index_plus(j,k);
        if eml_const(twidopt == SMALL_TWIDDLE_TABLE)
            % We are using a one-quadrant cosine table, so this is split
            % into two loops in order to extract twid = cos(j*e) +
            % sin(j*e)*1i from the table without adding logic in the loop.
            while j < nRowsD4
                if isInverse
                    twid = complex( ...
                        costab1q(eml_index_plus(j,1)), ...
                        costab1q(eml_index_plus(eml_index_minus(nRowsD4,j),1)));
                else
                    twid = complex( ...
                        costab1q(eml_index_plus(j,1)), ...
                        -costab1q(eml_index_plus(eml_index_minus(nRowsD4,j),1)));
                end
                i = istart;
                ihi = eml_index_plus(i,iheight);
                while i < ihi
                    temp = twid*y(eml_index_plus(eml_index_plus(i,iDelta),1));
                    y(eml_index_plus(eml_index_plus(i,iDelta),1)) = ...
                        y(eml_index_plus(i,1)) - temp;
                    y(eml_index_plus(i,1)) = y(eml_index_plus(i,1)) + temp;
                    i = eml_index_plus(i,iDelta2);
                end
                istart = eml_index_plus(istart,1);
                j = eml_index_plus(j,k);
            end
        end
        while j < nRowsD2
            if eml_const(twidopt == FULL_TWIDDLE_TABLE)
                twid = complex( ...
                    costab(eml_index_plus(j,1)), ...
                    sintab(eml_index_plus(j,1)));
            elseif eml_const(twidopt == SMALL_TWIDDLE_TABLE)
                if isInverse
                    twid = complex( ...
                        -costab1q(eml_index_plus(eml_index_minus(nRowsD2,j),1)), ...
                        costab1q(eml_index_plus(eml_index_minus(j,nRowsD4),1)));
                else
                    twid = complex( ...
                        -costab1q(eml_index_plus(eml_index_minus(nRowsD2,j),1)), ...
                        -costab1q(eml_index_plus(eml_index_minus(j,nRowsD4),1)));
                end
            else
                theta = e*cast(j,class(e));
                if isInverse
                    twid = complex(cos(theta),sin(theta));
                else
                    twid = complex(cos(theta),-sin(theta));
                end
            end
            i = istart;
            ihi = eml_index_plus(i,iheight);
            while i < ihi
                temp = twid*y(eml_index_plus(eml_index_plus(i,iDelta),1));
                y(eml_index_plus(eml_index_plus(i,iDelta),1)) = ...
                    y(eml_index_plus(i,1)) - temp;
                y(eml_index_plus(i,1)) = y(eml_index_plus(i,1)) + temp;
                i = eml_index_plus(i,iDelta2);
            end
            istart = eml_index_plus(istart,1);
            j = eml_index_plus(j,k);
        end
        k = rshift(k);
        iDelta = iDelta2;
        iDelta2 = eml_index_times(iDelta,2);
        iheight = eml_index_minus(iheight,iDelta);
    end
end
% Rescaling in the ifft case.
if isInverse && (size(y,1) > 1)
    r = eml_rdivide(ones(class(y)),size(y,1));
    y = y * r;
end

%--------------------------------------------------------------------------

function k = rshift(k)
eml_must_inline;
k = eml_cast( ...
    eml_rshift(eml_cast(k,ucls,'wrap'),ones(eml_index_class)), ...
    eml_index_class,'wrap');

%--------------------------------------------------------------------------

function j = eml_fft_bitrevidx(j,n)
% Compute index for bitreverse operation.
eml_must_inline;
tst = true;
while tst
    n = eml_rshift(n,ones(eml_index_class));
    j = eml_bitxor(j,n);
    tst = eml_bitand(j,n) == 0;
end

%--------------------------------------------------------------------------

function c = ucls
c = eml_unsigned_class(eml_index_class);

%--------------------------------------------------------------------------

function costab1q = make_1q_cosine_table(e,n)
% First-quadrant cosine table: costab = cos(e*(0:n)).
% This function has some tweaks to improve accuracy.
eml_must_inline;
eml_prefer_const(e,n);
costab1q = eml.nullcopy(zeros(1,eml_index_plus(n,1),class(e)));
costab1q(1) = 1;
nd2 = eml_index_rdivide(n,2);
for k = 1:nd2
    costab1q(eml_index_plus(k,1)) = cos(e*cast(k,class(e)));
end
for k = eml_index_plus(nd2,1):eml_index_minus(n,1)
    costab1q(eml_index_plus(k,1)) = sin(e*cast(eml_index_minus(n,k),class(e)));
end
costab1q(eml_index_plus(n,1)) = 0;

%--------------------------------------------------------------------------

function [costab,sintab] = make_twiddle_table(costab1q,isInverse)
% Generates a full table of complex twiddles from the one-quadrant cosine
% table.  The full table takes more memory but results in better
% performance in most cases.
eml_must_inline;
eml_prefer_const(costab1q,isInverse);
n = cast(size(costab1q,2)-1,eml_index_class);
n2 = eml_index_times(n,2);
N = eml_index_plus(n2,1);
costab = eml.nullcopy(zeros(1,N,class(costab1q)));
sintab = eml.nullcopy(zeros(1,N,class(costab1q)));
costab(1) = 1;
sintab(1) = 0;
if isInverse
    for k = 1:n
        costab(eml_index_plus(k,1)) = costab1q(eml_index_plus(k,1));
        sintab(eml_index_plus(k,1)) = costab1q(eml_index_plus(eml_index_minus(n,k),1));
    end
    for k = eml_index_plus(n,1):n2
        costab(eml_index_plus(k,1)) = -costab1q(eml_index_plus(eml_index_minus(n2,k),1));
        sintab(eml_index_plus(k,1)) = costab1q(eml_index_plus(eml_index_minus(k,n),1));
    end
else
    for k = 1:n
        costab(eml_index_plus(k,1)) = costab1q(eml_index_plus(k,1));
        sintab(eml_index_plus(k,1)) = -costab1q(eml_index_plus(eml_index_minus(n,k),1));
    end
    for k = eml_index_plus(n,1):n2
        costab(eml_index_plus(k,1)) = -costab1q(eml_index_plus(eml_index_minus(n2,k),1));
        sintab(eml_index_plus(k,1)) = -costab1q(eml_index_plus(eml_index_minus(k,n),1));
    end
end

%--------------------------------------------------------------------------

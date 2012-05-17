function y = median(x, dim)
%MEDIAN Median value of fixed-point array
%   Y = MEDIAN(X) computes the median value of the fixed-point array X 
%   along its first non-singleton dimension. 
%
%   Y = MEDIAN(X, DIM) computes the median value of the fixed-point array 
%   X along dimension DIM. DIM must be a positive, real-valued integer with a 
%   power-of-two slope and a bias of 0.
%
%   The fixed-point input array X must be real-valued.
%
%   The fixed-point output array Y has the same numerictype properties as the 
%   fixed-point input array X.
%
%   When X is an empty fixed-point array (value = []), the value of the 
%   output array is zero.
%
%   The fixed-point output array Y is always associated with the 
%   global fimath.
%
%   Refer to the MATLAB MEDIAN reference page for more information.
%
%   The following example computes the median of a 2-dimensional array.
%   The example first computes the MEDIAN along the first dimension 
%   of the input (rows), and then across the second dimension of 
%   the input (columns).
%
%   x = fi([0 1 2; 3 4 5; 7 2 2; 6 4 9], 1, 32)
%   % x is a signed FI object with 32-bit word length, and 27-bit (best
%   % precision) fraction length.
%   mx1 = median(x,1)
%   % mx1 is a FI object with value [4.5 3 3.5], and the same numerictype 
%   % properties as x
%   mx2 = median(x, 2)
%   % mx2 is a FI object with value [1; 4; 2; 6], and the same numerictype
%   % properties as x
%   See also EMBEDDED.FI/MEAN, MEDIAN

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:07:28 $

error(nargchk(1,2,nargin));
validateInputsToStatFunctions(x,'median');
if ~isreal(x)
    
    error('fi:median:supportForRealOnly', ...
        'Median only supports real-valued fixed-point input arrays.');
end
if (nargin == 2)
    
    if ~isnumeric(dim)
    
        error('fi:median:dimMustBeNumeric',...
            'Dimension input to ''median'' must be of type ''numeric''.');
    elseif (~isscalar(dim)||(dim <= 0)||~isreal(dim)||~isequal(floor(dim), dim))

        error('fi:median:dimMustBeRealPosScalarInt', ...
        'Dimension input to ''median'' must be a positive, real-valued integer.');
    end
else
    
    dim = 0;
end
dim = double(dim);
[y, ty, istrivial, dim] = ...
    fi_statop_trivial_cases_handler(x, dim, 'median');
if ~istrivial
    
    if (nargin == 1) && isvector(x)    
    
        y = vectormedian(x,ty);
    else
    
        vlen = size(x, dim);
        sx = size(x);
        sx(dim) = 1;
        y = fi(zeros(sx),ty);
        vwork = fi(zeros(vlen,1),ty);
        vstride = prod(sx(1:dim-1));
        vspread = (vlen - 1)*vstride;
        npages = prod(sx(dim+1 : ndims(x)));
        i2 = 0;
        iy = 0;
        for i = 1:npages

            i1 = i2;
            i2 = i2 + vspread;
            for j = 1:vstride

                i1 = i1 + 1;
                i2 = i2 + 1;
                ix = i1;
                for k = 1:vlen

                    temp = getElement(x,ix);
                    setElement(vwork, temp, k);
                    ix = ix + vstride;
                end
                iy = iy + 1;
                temp = vectormedian(vwork, ty);
                setElement(y, temp, iy);
            end
        end
    end
end
y.fimathislocal = false;


%-----------------------------------
function m = vectormedian(v, tv)

vlen = numberofelements(v);
midm1 = floor(vlen/2);
mid = midm1 + 1;
evenlength = (vlen == midm1*2);
v = sort(v);
if evenlength
    
    % m = fi(0, tv);
    % m(1) = (v(mid - 1) + v(mid))/2
    
    m = fi(0, tv);    
    elem1 = getElement(v,midm1);
    elem2 = getElement(v,mid);
    c = elem1+elem2;
    tc = numerictype(c);
    tcby2 = numerictype(tc, 'fractionlength', (tc.fractionlength+1));
    setElement(m,reinterpretcast(c,tcby2),1);
else    
    
    % m = v(mid)
    
    m = getElement(v,mid);
end

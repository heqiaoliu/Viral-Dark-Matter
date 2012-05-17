function yfi = pow2(xfi,K)
% Embedded MATLAB Library function for @fi/pow2.
%
% POW2(A,K) will return A.*(2^K), where K is a scalar

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/pow2.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.10 $  $Date: 2009/03/30 23:30:12 $

% Limitations
% 1) POW2(A) is not supported when A is a FI object.
% 2) K must be scalar in POW2(A,K) when A is a FI object. 
  
  
eml_allow_mx_inputs;  
  
eml_assert(nargin==2,'POW2(A) is not supported when A is a FI.');
eml_assert(isscalar(K),'K must be scalar in POW2(A,K) when A is a FI.');
eml_prefer_const(K);

if isfixed(xfi)
    % Fixed FI
    k = int32(floor(K));
    if k >= 0 % shift-left & check for saturation
        yfi = bitshift(xfi,k);
    else % shift-right, do rounding & check for saturation
        yHasLocalFimath = eml_const(eml_fimathislocal(xfi));
        if isreal(xfi)
            yfi = eml_fimathislocal(localPow2Right(xfi,k),yHasLocalFimath);
        else
            yr = localPow2Right(real(xfi),k);
            yi = localPow2Right(imag(xfi),k);
            yfi = eml_fimathislocal(complex(yr,yi),yHasLocalFimath);
        end
    end
elseif isfloat(xfi)
    % True Double or True Single FI

    if isreal(xfi)
        xTemp = eml_cast(xfi,eml_fi_getDType(xfi));
        pow2X = pow2(xTemp, K);
        yfi   = eml_cast(pow2X,eml_typeof(xfi),eml_fimath(xfi));
    else
        dType   = eml_fi_getDType(xfi);
        xRe     = real(xfi);
        xTempRe = eml_cast(xRe,dType);
        pow2XRe = pow2(xTempRe, K);
        xIm     = imag(xfi);
        xTempIm = eml_cast(xIm,dType);
        pow2XIm = pow2(xTempIm, K);
        
        yfi     = eml_cast(complex(pow2XRe,pow2XIm),eml_typeof(xfi),eml_fimath(xfi));
    end

else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('POW2','fixed-point,double, or single');
end
  
%--------------------------------------------------------------------------------------------
function y1 = localPow2Right(x,k)
% When k is negative do a right shift & then check for the rounding
x1 = bitshift(x,k);
y1 = doRounding(x,x1,-k);

%--------------------------------------------------------------------------------------------
function y = doRounding(xorig,x,k)
% Do the rounding & overflow check in this function

eml.extrinsic('eml_iscomplexroundmode_helper');
F = fimath(x);
y = x;
lx = eml_numel(x);
lsbx = lsb(x(1));


% {'ceil','convergent','fix','floor','nearest','round'};

if eml_const(eml_iscomplexroundmode_helper(F,'ceil'))
    % If droppedbits have any bit set then round up
    for idx = 1:lx
         if lastBitShiftedIsOne(xorig(idx),k) || nonZeroDroppedBitsRightOfLastBit(xorig(idx),k) 
            y(idx) = addXLsbx(x(idx),lsbx);
        end
    end
elseif eml_const(eml_iscomplexroundmode_helper(F,'convergent'))
    % round to even number
    % the number should be rounded up 
    % if
    % the last bit to be shifted off the right is 1
    % &&
    % (the bits right of the last bit are not all zero.
    %  || 
    %  the bit left of the last bit to be shifted off 
    %  is not zero (odd value))
    for idx = 1:lx
        if lastBitShiftedIsOne(xorig(idx),k) && (nonZeroDroppedBitsRightOfLastBit(xorig(idx),k) || bitget(x(idx),1)==1) 
            y(idx) = addXLsbx(x(idx),lsbx);
        end
    end
elseif eml_const(eml_iscomplexroundmode_helper(F,'fix'))
    % If number is negative and droppedbits > 0 then roundup
    for idx = 1:lx
        if (x(idx) < 0) && (lastBitShiftedIsOne(xorig(idx),k) || ...
                            nonZeroDroppedBitsRightOfLastBit(xorig(idx),k))
            y(idx) = addXLsbx(x(idx),lsbx);
        end
    end
elseif eml_const(eml_iscomplexroundmode_helper(F,'nearest'))
    for idx = 1:lx
        if lastBitShiftedIsOne(xorig(idx),k)
            y(idx) = addXLsbx(x(idx),lsbx);
        end
    end
elseif eml_const(eml_iscomplexroundmode_helper(F,'round'))
    % The number is rounded
    % if
    % the last bit to be shifted off the right is 1
    % &&
    % (the value is positive
    %  ||
    %  the value is negative &&
    %  the bits right of the last bit are not all zero.)
    for idx = 1:lx
        if x(idx)>=0 && lastBitShiftedIsOne(xorig(idx),k) 
            y(idx) = addXLsbx(x(idx),lsbx);
        elseif x(idx)<0 && lastBitShiftedIsOne(xorig(idx),k) && ...
                nonZeroDroppedBitsRightOfLastBit(xorig(idx),k)
            y(idx) = addXLsbx(x(idx),lsbx);
        end
    end
end

%-------------------------------------------------------------
function y = addXLsbx(x,lsbx)
% Add x with lsbx, using tailor-made fimath if required
wl = get(x,'wordlength');
fl = get(x,'fractionlength');
fx = fimath(x);

f = fimath(fx,'summode','specifyprecision','sumwordlength',wl,'sumfractionlength',fl);
xf = fi(x,'fimath',f);
lsbxf = fi(lsbx,'fimath',f);
yf = xf + lsbxf;
y = fi(yf,'fimath',fx);

%----------------------------------------------------------------------------------------------
function flag = nonZeroDroppedBitsRightOfLastBit(x,k)
% Return true if there are non-zero bits on the right of the last shifted bit

flag = false;

% If k is  > x.WordLength bits on the right of the "last shifted bit" starts with the MSB 
xWL = get(x,'WordLength');
if k > xWL
    kstart = xWL;
else
    kstart = double(k-1);
end
for idx = kstart:-1:1
    flag = flag || (bitget(x,idx)==1);
end
    
%---------------------------------------------------------------------------------------------
function flag = lastBitShiftedIsOne(x,k)
% Return true if the last shifted bit is set.

% If k is > x.Wordlength return false, unless the number is negative valued
if k > get(x,'WordLength')
    if x<0
        flag = true;
    else
        flag = false;
    end
else
    flag = (bitget(x,k)==1);
end

%-----------------------------------------------------------------------------------------------

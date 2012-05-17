function Tb = emlGetMinWlenAndPrecisionForMxArray(const, bias)
%emlGetMinWlenAndPrecision  Get minimum word length and precision for a
%constant.
%
%   Example:
%     Tb = emlGetMinWlenAndPrecisionForMxArray(0.96875)
%        returns numerictype(0, 4, 4)
%
%     Tb = emlGetMinWlenAndPrecisionForMxArray(16.96875)
%        returns numerictype(0, 8, 4)

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/10/24 19:03:59 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: this function has 32 bit limitation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxWordLen = 32;

% get min precision numerictype for const with min wlen
const1 = const - (2*bias);

isSigned = get_sign(const1);

minIntL = get_intlen(const1);

if isinteger(const1)
    minFL = 0;
else
    minFL = get_flen(const1-floor(const1));
end
minFL = min(minFL, maxWordLen - minIntL - isSigned);

numBits = abs(minIntL) + abs(minFL);

if  ~isequal(bias,0)
    Tb = numerictype(isSigned,numBits,1,-minFL,bias);
else
    Tb = numerictype(isSigned,numBits,minFL);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function issigned = get_sign(const)
issigned = double(any(const(:) < 0));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function intLen = get_intlen(const)
A = max(abs(const(:)));
if (A==0)
    intLen = 1;
elseif (A<1)
    intLen = get_sign(const);
else
    % log2 not defined for integers
    intLen = floor(log2(double(A))) + 1 + get_sign(const);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flen = get_flen(const)

maxWordLen = 32;

[X,Y] = meshgrid(const,pow2(0:maxWordLen));
xv = X.*Y;
xv = xv-floor(xv);
[actual_min, index] = min(xv);
flen = max(index)-1;
if actual_min ~= 0 %|| isempty(flen)
    % const has irrational fractional part
    flen = maxWordLen; 
end



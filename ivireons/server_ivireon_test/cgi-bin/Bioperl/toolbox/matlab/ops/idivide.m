function c = idivide(a,b,opt)
%IDIVIDE  Integer division with rounding option.
% 
%   C = IDIVIDE(A,B,OPT) is the same as A ./ B for integer classes except 
%   that fractional quotients are rounded to integers using the optional 
%   rounding mode specified by OPT.  The default rounding mode is 'fix'.  
%   A and B must be real and must have the same dimensions unless one is a 
%   scalar.  At least one of the arguments A and B must belong to an 
%   integer class, and the other must belong to the same integer class or 
%   be a scalar double.  The result C belongs to the integer class.
% 
%   C = IDIVIDE(A,B) and
%   C = IDIVIDE(A,B,'fix') are the same as A./B except that fractional 
%   quotients are rounded toward zero to the nearest integers.
% 
%   C = IDIVIDE(A,B,'round') is the same as A./B for integer classes. 
%   Fractional quotients are rounded to the nearest integers.
% 
%   C = IDIVIDE(A,B,'floor') is the same as A./B except that fractional 
%   quotients are rounded toward negative infinity to the nearest integers.
% 
%   C = IDIVIDE(A,B,'ceil') is the same as A./B except that the fractional 
%   quotients are rounded toward infinity to the nearest integers.
%
%   Examples
%      a = int32([-2 2]);
%      b = int32(3);
%      idivide(a,b) returns [0 0]
%      idivide(a,b,'floor') returns [-1 0]
%      idivide(a,b,'ceil') returns [0 1]
%      idivide(a,b,'round') returns [-1 1]
% 
%   See also LDIVIDE, RDIVIDE, MLDIVIDE, MRDIVIDE. 

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2005/11/18 14:15:55 $

if nargin < 2
    error('MATLAB:idivide:minrhs','Not enough input arguments.');
end

idivide_check(a,b);

if nargin < 3 || strcmpi(opt,'fix')
    c = idivide_fix(a,b);
elseif strcmpi(opt,'floor')
    c = idivide_floor(a,b);
elseif strcmpi(opt,'ceil')
    c = idivide_ceil(a,b);
elseif strcmpi(opt,'round')
    c = a ./ b;
else
    error('MATLAB:idivide:InvalidRoundingOption', ...
        'Unrecognized rounding option.'); 
end

%--------------------------------------------------------------------------

function idivide_check(a,b)
% Validate input.
aint = isinteger(a);
bint = isinteger(b);
if ~(isequal(size(a),size(b)) || isscalar(a) || isscalar(b))
    error('MATLAB:idivide:dimagree','Matrix dimensions must agree.');
end
if ~(aint || bint)
    error('MATLAB:idivide:OneArgumentMustBeInteger', ...
        'At least one argument must belong to an integer class.');
end
if ~(isreal(a) && isreal(b))
    error('MATLAB:idivide:complexInts', ...
        'Complex integer arithmetic is not supported.');
end
if ~(aint && bint && isa(a,class(b))) && ...
        ~(aint && isa(b,'double') && isscalar(b)) && ...
        ~(bint && isa(a,'double') && isscalar(a))
    error('MATLAB:idivide:mixedClasses', ...
        'Integers can only be combined with integers of the same class, or scalar doubles.');
end

%--------------------------------------------------------------------------

function c = idivide_fix(a,b)
% Integer division with rounding towards zero.
if isfloat(a)
    c = cast( fix( a ./ double(b) ) , class(b) );
elseif isfloat(b)
    c = cast( fix( double(a) ./ b ) , class(a) );
else
    c = (a - rem(a,b)) ./ b;
end

%--------------------------------------------------------------------------

function c = idivide_floor(a,b)
% Integer division with rounding towards negative infinity.
if isfloat(a)
    c = cast( floor( a ./ double(b) ) , class(b) );
elseif isfloat(b)
    c = cast( floor( double(a) ./ b ) , class(a) );
else
    c = (a - rem(a,b)) ./ b;
    idx = (b ~= 0) & (sign(a) ~= sign(b)) & ((b .* c) ~= a);
    c(idx) = c(idx) - 1;
end

%--------------------------------------------------------------------------

function c = idivide_ceil(a,b)
% Integer division with rounding towards infinity.
if isfloat(a)
    c = cast( ceil( a ./ double(b) ) , class(b) );
elseif isfloat(b)
    c = cast( ceil( double(a) ./ b ) , class(a) );
else
    c = (a - rem(a,b)) ./ b;
    idx = (b ~= 0) & (sign(a) == sign(b)) & ((b .* c) ~= a);
    c(idx) = c(idx) + 1;
end

%--------------------------------------------------------------------------

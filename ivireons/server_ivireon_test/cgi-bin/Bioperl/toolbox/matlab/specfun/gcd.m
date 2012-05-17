function [g,c,d] = gcd(a,b)
%GCD    Greatest common divisor.
%   G = GCD(A,B) is the greatest common divisor of corresponding elements
%   of A and B.  The arrays A and B must contain integer values and must be
%   the same size (or either can be scalar). GCD(0,0) is 0 by convention;
%   all other GCDs are positive integers.
%
%   [G,C,D] = GCD(A,B) also returns C and D so that G = A.*C + B.*D.
%   These are useful for solving Diophantine equations and computing
%   Hermite transformations.
%
%   Class support for inputs A,B:
%      float: double, single
%
%   See also LCM.
 
%   Algorithm: See Knuth Volume 2, Section 4.5.2, Algorithm X.
%
%   Thanks to John Gilbert
%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 5.14.4.4 $  $Date: 2008/09/13 06:57:21 $

classin = superiorfloat(a,b);

% Do scalar expansion if necessary
if isscalar(a)
   a = a(ones(size(b)));
elseif isscalar(b)
   b = b(ones(size(a)));
end

if ~isequal(size(a),size(b))
    error('MATLAB:gcd:InputSizeMismatch', 'Inputs must be the same size.')
else
    siz = size(a);
    a = a(:); b = b(:);
end

if isNotRealIntegerValue(a) || isNotRealIntegerValue(b)
    error('MATLAB:gcd:NonIntInputs', 'Inputs must be real integers.')
end

warnIfGreatThanLargestFlint(a,b,classin);

c = zeros(size(a),classin);
d = zeros(size(a),classin);
g = zeros(size(a),classin);
for k = 1:length(a)
   u = [1 0 abs(a(k))];
   v = [0 1 abs(b(k))];
   while v(3)
       q = floor( u(3)/v(3) );
       t = u - v*q;
       u = v;
       v = t;
   end
 
   c(k) = u(1) * sign(a(k));
   d(k) = u(2) * sign(b(k));
   g(k) = u(3);
end

c = reshape(c,siz);
d = reshape(d,siz);
g = reshape(g,siz);

function flag = isNotRealIntegerValue(A)
flag = ~isreal(A) || ~isequal(round(A),A) || any(isinf(A(:)));

function warnIfGreatThanLargestFlint(A,B,classCheck)
if strcmp(classCheck,'double')
   largestFlint = 2^53-1;
else % single
   largestFlint = 2^24-1;
end
if any(abs(A(:)) > largestFlint) || any(abs(B(:)) > largestFlint)
    warning('MATLAB:gcd:largestFlint', ...
           ['Inputs contain values larger than the largest consecutive flint.\n', ...
            '         Result may be inaccurate.']);
end

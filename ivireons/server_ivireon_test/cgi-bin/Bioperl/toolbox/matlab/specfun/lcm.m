function c = lcm(a,b)
%LCM    Least common multiple.
%   LCM(A,B) is the least common multiple of corresponding elements of
%   A and B.  The arrays A and B must contain positive integers
%   and must be the same size (or either can be scalar).
%
%   Class support for inputs A,B:
%      float: double, single
%
%   See also GCD.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.10.4.2 $  $Date: 2004/07/05 17:02:04 $

if any(round(a(:)) ~= a(:) | round(b(:)) ~= b(:) | a(:) < 1 | b(:) < 1)
    error('MATLAB:lcm:InputNotPosInt',...
          'Input arguments must contain positive integers.');
end
c = a.*(b./gcd(a,b));

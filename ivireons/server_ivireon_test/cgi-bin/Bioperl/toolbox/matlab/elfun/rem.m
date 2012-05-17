%REM    Remainder after division.
%   REM(x,y) is x - n.*y where n = fix(x./y) if y ~= 0.  If y is not an
%   integer and the quotient x./y is within roundoff error of an integer,
%   then n is that integer. The inputs x and y must be real arrays of the
%   same size, or real scalars.
%
%   By convention:
%      REM(x,0) is NaN.
%      REM(x,x), for x~=0, is 0.
%      REM(x,y), for x~=y and y~=0, has the same sign as x.
%
%   Note: MOD(x,y), for x~=y and y~=0, has the same sign as y.
%   REM(x,y) and MOD(x,y) are equal if x and y have the same sign, but
%   differ by y if x and y have different signs.
%
%   See also MOD.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.13.4.5 $  $Date: 2005/06/21 19:28:11 $
%   Built-in function.


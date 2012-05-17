function c = mrdivide(a,b)
%/   Slash or right matrix divide.
%    MRDIVIDE(A,B) is called for A/B.
%
%    If either A or B is a fi object, then B must be a scalar in the
%    expression A/B, and the output is the same as A./B.
%
%    The data-type rules are found in the help for EMBEDDED.FI/RDIVIDE.
%
%    See also EMBEDDED.FI/RDIVIDE, MRDIVIDE.

%   Thomas A. Bryan and Becky Bryan, 30 December 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/23 18:51:34 $

if prod(size(b)) ~= 1 %#ok numel doesn't work for fi objects
    error('fi:mrdivide:NonScalarDivisor',...
          'For fi objects, B must be a scalar in A/B.');
end
T = computeDivideType(a,b);
c = divide(T,a,b);

    
    

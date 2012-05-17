function x = eq(A, B)
%EQ True for equal VRNODE objects.
%   EQ(A,B) compares two VRNODE objects, or two vectors of VRNODE objects
%   (which must be of the same size), or a vector of VRNODE objects
%   with a single VRNODE object.
%   Two valid VRNODE objects are considered equal if they refer to
%   the same node. An invalid VRNODE object is considered nonequal
%   to any VRNODE object, including itself.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/11/07 21:29:52 $ $Author: batserve $

% check parameters
if ~isa(A, 'vrnode') || ~isa(B, 'vrnode')
  error('VR:invalidinarg', 'Both arguments must be of type VRNODE.');
end

% Scalar expansion
if any(size(A) ~= size(B))
  if numel(A)==1
    A = A(ones(size(B)));
  elseif numel(B)==1
    B = B(ones(size(A)));
  else
    error('VR:dimnotagree', 'Matrix dimensions must agree.');
  end
end
    
% do it
x = false(size(A));
for k = 1:numel(A)
  x(k) = isvalid(A(k)) && isvalid(B(k)) && (A(k).World==B(k).World) ...
         && strcmp(A(k).Name, B(k).Name);
end

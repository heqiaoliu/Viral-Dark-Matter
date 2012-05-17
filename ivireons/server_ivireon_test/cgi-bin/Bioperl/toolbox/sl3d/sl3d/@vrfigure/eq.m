function x = eq(A, B)
%EQ True for equal VRFIGURE handles.
%   EQ(A,B) compares two VRFIGURE handles, or two vectors of VRFIGURE handles
%   (which must be of the same size), or a vector of VRFIGURE handles
%   with a single VRFIGURE handle.
%   Two VRFIGURE handles are considered equal if they refer to
%   the same figure. An invalid VRFIGURE handle is considered nonequal
%   to any VRFIGURE handle, including itself.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2009/11/07 21:29:50 $ $Author: batserve $

% check parameters
if ~isa(A, 'vrfigure') || ~isa(B, 'vrfigure')
  error('VR:invalidinarg', 'Both arguments must be of type VRFIGURE.');
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
  x(k) = isvalid(A(k)) && isvalid(B(k)) && ...
         ( (A(k).handle==B(k).handle) && (A(k).handle~=0) || ...
           (A(k).figure==B(k).figure) && (A(k).figure~=0) );
end

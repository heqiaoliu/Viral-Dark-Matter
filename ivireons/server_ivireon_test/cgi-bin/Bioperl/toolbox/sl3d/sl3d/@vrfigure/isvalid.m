function x = isvalid(f)
%ISVALID True for valid VRFIGURE objects.
%   X = ISVALID(F) returns a logical array that contains a 0
%   where the elements of F are invalid VRFIGURE handles
%   and 1 where the elements of F are valid VRFIGURE handles.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2009/05/07 18:29:22 $ $Author: batserve $

x = false(size(f));
vf = vrsfunc('GetAllFigures');  
for i=1:numel(f)
  x(i) = any(f(i).handle==vf);
  if isa(f(i).figure, 'vr.figure')
    x(i) = x(i) | isvalid(f(i).figure);
  end
end

function close(f)
%CLOSE Close a virtual reality figure.
%   CLOSE(F) closes a virtual reality figure referenced by VRFIGURE handle F.
%   If F is a vector of VRFIGURE handles multiple figures are closed.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/12/21 01:51:55 $ $Author: batserve $

for i = 1:numel(f)
  if f(i).handle
    vrsfunc('VRT3RemoveView', f(i).handle);
  else
    if isa(f(i).figure, 'vr.figure') %;!! close only if class exists
      close(f(i).figure);
    end
  end
end

function th = getParameterVector(nlobj)
%getParameterVector returns the parameter vector of idnlfunVector object.
%
%  vector = getParameterVector(nlobj) where nlobj is an idnlfunVector object.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:36 $

% Author(s): Qinghua Zhang

if ~isinitialized(nlobj)
  th = [];
  return
end

th = [];
for ky=1:numel(nlobj)
  th = [th; sogetParameterVector(nlobj.ObjVector{ky})];
end

% FILE END
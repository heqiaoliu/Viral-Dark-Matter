function th = getParameterVector(nlobj)
%getParameterVector returns the parameter vector of IDNLFUN objects.
%
%  vector = getParameterVector(nlobj) where nlobj is an IDNLFUN object array.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:05 $

% Author(s): Qinghua Zhang

if ~isinitialized(nlobj)
  th = [];
  return
end

th = [];
for ky=1:numel(nlobj)
  th = [th; sogetParameterVector(nlobj(ky))]; 
end

% FILE END
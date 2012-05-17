function status = isproperty(obj, prop)
%ISPROPERTY returns True if the property exists
%
%  ISPROPERTY(OBJ, PROP) returns true if PROP is a public property of OBJ.
%  For an array of objects, it returns true if PROP is a property
%  of all the objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:18 $

% Author(s): Qinghua Zhang

if isa(obj, 'idnlfun')
  status = true;
else
  status = false;
  return
end

for k=1:numel(obj)
  if ~isfield(get(obj), prop)
    status = false;
    return
  end
end

% FILE END

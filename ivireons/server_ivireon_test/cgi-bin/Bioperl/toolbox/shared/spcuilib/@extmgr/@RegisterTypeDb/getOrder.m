function order = getOrder(this,theType)
%GETORDER Return order of instantiation and position in dialog.
%  GETORDER(H,'theType') returns specified extension order as
%  specified in database.  If type not found, the default position
%  0 is returned.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:32 $

hRegisterType = findType(this,theType);
if isempty(hRegisterType)
    order = 0;
else
    order = hRegisterType.Order;
end

% [EOF]

function c = getConstraint(hRegisterTypeDb,theType)
%GETCONSTRAINT Return constraint corresponding to extension type.
%  GETCONSTRAINT(H,'theType') returns specified extension constraint
%  specified in database.  If type not found, the default constraint
%  'EnableAny' is returned.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/03/17 22:38:31 $

hRegisterType = findType(hRegisterTypeDb,theType);
if isempty(hRegisterType)
    c = extmgr.EnableAny(theType);
else
    c = hRegisterType.Constraint;
end

% [EOF]

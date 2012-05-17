function [success, exception] = validate(this)
%VALIDATE Validate all property settings in dialog, by running
%   validate method on all extensions that define one.
%   Also, confirm type-group constraints are met (i.e., that
%   enables are consistent with type constraints EnableOne,
%   EnableAll, etc)
%
% success: boolean status, 0=fail, 1=accept
% errMsg: error message, string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/07/23 18:44:07 $

% Prepare for success:
success = true;
exception = MException.empty;

hRegisterDb     = this.Driver.RegisterDb;
hRegisterTypeDb = hRegisterDb.RegisterTypeDb;
hConfigDb       = this.Driver.ConfigDb;
hDialog         = this.Dialog;

% Visit constraint for each type.  As soon as we hit an invalid constraint,
% we return.
allTypes = getUniqueTypes(hRegisterDb);
for i=1:numel(allTypes)
    type = allTypes{i};
    c = getConstraint(hRegisterTypeDb,type);
    
    [success, exception] = c.validate(hConfigDb, hRegisterDb, hDialog);
    if ~success
        return;
    end
end

% [EOF]

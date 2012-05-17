function data = getAppData(this, type, name, field)
%GETAPPDATA Add data to the register.
%   GETAPPDATA(H, TYPE, NAME, FIELD) returns the application data saved in
%   the register object specified by TYPE and NAME in the field, FIELD.
%   GENVARNAME is used to convert any invalid field names.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/02/02 13:10:07 $

hRegister = this.findRegister(type, name);
if isempty(hRegister)
    
    % If the extension has not yet been registered, any application data
    % that has been added for it, is stored in "CachedApplicationData".
    type  = genvarname(type);
    name  = genvarname(name);
    field = genvarname(field);
    cAppData = get(this, 'CachedApplicationData');
    if isfield(cAppData, type) && ...
            isfield(cAppData.(type), name) && ...
            isfield(cAppData.(type).(name), field)
        data = this.CachedApplicationData.(type).(name).(field);
    else
        data = [];
    end
else
    data = hRegister.getAppData(field);
end

% [EOF]

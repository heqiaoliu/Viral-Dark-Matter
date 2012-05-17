function setAppData(this, type, name, field, data)
%SETAPPDATA Add data to the register.
%   SETAPPDATA(H, TYPE, NAME, FIELD, DATA) sets the application data, DATA,
%   to the register object specified by TYPE and NAME in the field, FIELD.
%   GENVARNAME is used to convert any invalid field names.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:40:07 $

hRegister = this.findRegister(type, name);
if isempty(hRegister)
    % We need to support this because we cannot guarantee registration
    % order and someone might want to add application data in a
    % registration file that gets called before the extension gets
    % registered.  Cache the data and set it later in the ADD method.
    type  = genvarname(type);
    name  = genvarname(name);
    field = genvarname(field);
    this.CachedApplicationData.(type).(name).(field) = data;
else
    hRegister.setAppData(field, data);
end

% [EOF]

function hObject = getObjectFromPath(this, path)
%GETOBJECTFROMPATH Get the objectFromPath.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:02 $

if strncmpi(path, 'Register Types', 14)
    hObject = this.RegisterTypeDb;
    [regtypedb, regtype] = strtok(path, '/');
    
    if isempty(regtype)
        return;
    end
    
    regtype(1) = [];
    
    hObject = hObject.getObjectFromPath(regtype);
else
    
    path = strrep(path, '//', '<SLASH>');
    
    [reg, path] = strtok(path, '/');
    
    reg = strrep(reg, '<SLASH>', '/');
    
    [type, name] = strtok(reg, '.');
    name(1) = [];

    hObject = this.findRegister(type, name);
    
    if isempty(path)
        return;
    end
    
    path(1) = [];
    
    hObject = hObject.getObjectFromPath(path);
end


% [EOF]

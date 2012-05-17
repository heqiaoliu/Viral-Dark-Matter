function currentnode = set_currentnode(this, currentnode)
%SET_CURRENTNODE PreSet function for the 'currentnode' property

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:21 $

if isempty(currentnode)
    currentnode = 'Library';
end

set(this, 'CurrentObject', getCurrentObject(currentnode));

% -------------------------------------------------------------------------
function currentObject = getCurrentObject(currentnode)

currentObject = extmgr.RegisterLib;
[lib, path] = strtok(currentnode, '/');

if isempty(path)
    return;
end

currentObject = currentObject.getObjectFromPath(path);
% 
% regdb(1) = [];
% 
% [regdb, reg] = strtok(regdb, '/');
% 
% currentObject = currentObject.getRegisterDb(regdb);
% 
% if isempty(reg)
%     return;
% end
% 
% reg(1) = [];
% 
% if strncmpi(reg, 'Register Types', 14)
%     currentObject = currentObject.hRegisterTypeDb;
%     [regtypedb, regtype] = strtok(reg, '/');
%     
%     if isempty(regtype)
%         return;
%     end
%     
%     regtype(1) = [];
%     
%     currentObject = currentObject.findtype(regtype);
% else
%     
%     reg = strrep(reg, '//', '<SLASH>');
%     
%     [reg, res] = strtok(reg, '/');
%     
%     reg = strrep(reg, '<SLASH>', '/');
%     
%     [type, name] = strtok(reg, '.');
%     name(1) = [];
% 
%     currentObject = currentObject.findRegister(type, name);
%     
%     if isempty(res)
%         return;
%     end
%     
%     res(1) = [];
%     
%     [res, prop] = strtok(res, '/');
%     
%     currentObject = currentObject.Resources;
%     
%     if isempty(prop)
%         return;
%     end
%     
%     prop(1) = [];
%     
%     currentObject = currentObject.Properties.findProp(prop);
% end

% [EOF]

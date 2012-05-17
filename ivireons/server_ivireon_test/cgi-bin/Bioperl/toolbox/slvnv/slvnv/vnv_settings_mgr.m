function out = vnv_settings_mgr(method,variable,value)
%SETTINGS_MGR - Cached management of persistent variables for RMI

%  Copyright 1984-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.9 $  $Date: 2010/04/05 22:58:11 $

    warning('SLVnV:slvnv:vnv_settings_mgr', 'vnv_settings_mgr() is deprecated. Use rmi.settings_mgr() instead.');
    
    if nargin > 2 % set
        rmi.settings_mgr(method, variable, value);
    else % get
        out = rmi.settings_mgr(method, variable);
    end
    

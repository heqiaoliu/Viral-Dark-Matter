function this = UserIntfExt(hAppInst, hExtReg, hExtCfg) %#ok
%SrcOptsExt Manage user-I/O related options (buttons, keys, etc).
%   A "required" extension that allows user to manage properties
%   and behaviors affecting the scope user-interface.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/12/14 15:03:08 $

this = uiscopes.UserIntfExt;
this.init(hAppInst, hExtReg, hExtCfg);
this.enableGUIHandler = handle.listener(hAppInst,...
    'DataLoadedEvent',@(h, ev)enableGUI(this,ev));

propertyChanged(this, 'ShowNewAction');

% [EOF]

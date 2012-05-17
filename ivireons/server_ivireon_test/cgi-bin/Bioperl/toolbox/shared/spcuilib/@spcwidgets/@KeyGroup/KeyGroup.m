function h = KeyGroup(theName)
%KeyGroup Constructor for spcwidgets.KeyHandlerBinding
%   KeyGroup creates a key handler binding object that binds
%   key presses in a figure to the execution of specific functions.  It
%   also provides help text used by the KeyHandler object to construct a
%   help dialog describing all key binding operations.
%
%   KeyGroup(NAME) specifies a NAME for the binding group as a string,
%   which must be unique across all child handlers.  NAME is also used to
%   graphically delineate text sections within the key-command help dialog.
%

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/07/23 18:44:19 $

h = spcwidgets.KeyGroup;
h.Name = theName;  % must be specified

% If Enable is changed, update the dialog (only if it's already open)
h.Listeners = handle.listener(h, ...
    h.findprop('Enabled'), ...
    'PropertyPostSet', @(h1,ev)show(h,false));

% [EOF]

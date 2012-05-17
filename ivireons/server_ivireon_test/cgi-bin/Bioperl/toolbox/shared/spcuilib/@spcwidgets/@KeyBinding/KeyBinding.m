function h = KeyBinding(varargin)
%KeyBinding Constructor for spcwidgets.KeyBinding
%   Keybinding creates a key binding object that binds key presses in a
%   figure to the execution of specific functions.  It also provides help
%   text used by the KeyMgr object to construct a help dialog describing
%   all key binding operations.
%
%   KeyBinding(ID,FCN,HELP) specifies key identifier string ID for the
%   binding, function handle FCN for the binding function, and help string
%   HELP describing the binding function.  FCN must take a handle to the
%   binding object as the only argument.
%
%   Multiple binding functions may be provided to the KeyGroup object,
%   each performing one key binding for an application.
%   The key binding supported by one KeyBinding object may be
%   enabled or disabled separately from all other binding objects.
%   Multiple KeyBinding objects may be added to the parent
%   KeyGroup object as desired.
%
%   KeyBinding(...,HELPID) specifies an alternative string HELPID used
%   for display in the help dialog.  When empty, the ID string is used
%   in the help dialog.
%
%   KeyBinding(...,HELPID,HELPGROUP) specifies a help group string that
%   overrides the default name of the help group, which is usually taken
%   from the Name property of the parent KeyGroup object.
%
%   The key binding function must implement the following interface:
%
%     function myBindingFcn(hBinding)
%
%   where isHit is returned as TRUE if the key binding function found
%   a matching function to execute based on the key.  This flag stops the
%   KeyHandler object from executing additional key binding functions,
%   since a matching binding was found.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/07/23 18:44:18 $

h = spcwidgets.KeyBinding;
uiservices.deal2props(varargin,h,{'KeyId','Fcn','Help','HelpId','HelpGroup'});

% If Enable is changed, update the dialog (only if it's already open)
h.Listeners = handle.listener(h, ...
    h.findprop('Enabled'), ...
    'PropertyPostSet', @(h1,ev)show(h,false));

h.Listeners = handle.listener(h, ...
    h.findprop('Visible'), ...
    'PropertyPostSet', @(h1,ev)show(h,false));



% [EOF]

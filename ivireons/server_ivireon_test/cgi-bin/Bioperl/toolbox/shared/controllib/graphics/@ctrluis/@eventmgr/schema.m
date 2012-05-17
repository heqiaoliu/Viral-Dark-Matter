function schema
% Defines properties for @eventmgr base class.
%
% This class and its subclasses define generic interfaces for managing events 
% and actions.  This includes:
%   * Mouse selection
%   * Mouse edits
%   * Event recording (history, undo, redo)
%   * Status management

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:26 $

% Register class 
c = schema.class(findpackage('ctrluis'),'eventmgr');

% Public properties
p = schema.prop(c, 'MouseEditMode', 'on/off');        % Keeps track of dynamic mouse edits
schema.prop(c, 'SelectedContainer', 'handle');        % Container containing selected objects
schema.prop(c, 'SelectedObjects', 'handle vector');   % List of mouse selected items

% Private properties
p(1) = schema.prop(c, 'Listeners', 'handle vector');           % Listeners
p(2) = schema.prop(c, 'SelectedListeners', 'handle vector');   % Listeners to selected objects
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

% Events
schema.event(c,'MouseEdit');   % Issued at each sample during mouse edits (move, resize,...)
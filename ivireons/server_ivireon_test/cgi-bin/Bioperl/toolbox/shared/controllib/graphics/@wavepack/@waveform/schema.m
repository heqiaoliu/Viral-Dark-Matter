function schema
%SCHEMA  Class definition of @waveform (time or frequency wave).

%  Author(s): Bora Eryilmaz
%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:53:11 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'dataview');
c = schema.class(findpackage('wavepack'), 'waveform', superclass);

% Public attributes
schema.prop(c, 'Characteristics','handle vector'); % Response char. (@dataview)
schema.prop(c, 'ColumnIndex','MATLAB array');  % Input channels
schema.prop(c, 'Context',        'MATLAB array');  % Context info (plot type, x0,...)
schema.prop(c, 'DataSrc',        'handle');        % Data source (@respsource)
p = schema.prop(c, 'Name',           'string');        % Response array name
p.setfunction = {@LocalSetName};
schema.prop(c, 'RowIndex',   'MATLAB array');  % Output channels
schema.prop(c, 'Style',          'handle');        % Style
schema.prop(c, 'Group', 'MATLAB array');    % Curve groups for legend

% Private attributes
p = schema.prop(c, 'DataChangedListener', 'handle vector');
p = schema.prop(c, 'DataSrcListener', 'handle');
p = schema.prop(c, 'StyleListener', 'handle');
p = schema.prop(c, 'NameListenerData', 'MATLAB array'); % ListenerManager Class
p = schema.prop(c, 'NameListener', 'MATLAB array'); % Virtual ListenerManager Class
p.GetFunction = @LocalGetNameListenerValue;
set(p,'AccessFlags.PublicGet','on','AccessFlags.PublicSet','off', ...
    'AccessFlags.PrivateSet','off');  

p = schema.prop(c, 'SelectedListenerData', 'MATLAB array'); % ListenerManager Class
p = schema.prop(c, 'SelectedListener', 'MATLAB array'); % Virtual ListenerManager Class
p.GetFunction = @LocalGetSelectedListenerValue;
set(p,'AccessFlags.PublicGet','on','AccessFlags.PublicSet','off', ...
    'AccessFlags.PrivateSet','off');  

p = schema.prop(c, 'CharacteristicManager', 'MATLAB array');    % Characteristics manager
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'off');


p = schema.prop(c, 'DoUpdateName', 'MATLAB array'); % bypass listener flag
% REVISIT: make it private when local function limitation is gone
% set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

% Event
schema.event(c, 'DataChanged');


% ------------------------------------------------------------------------%
% Function: LocalSetName
% Purpose:  Update Group legendinfo for legend when name changes
% ------------------------------------------------------------------------%
function ProposedValue = LocalSetName(this, ProposedValue)

this.updateGroupInfo(ProposedValue);


function StoredValue = LocalGetNameListenerValue(this,StoredValue)
if isempty(this.NameListenerData)
    this.NameListenerData = controllibutils.ListenerManager;
end
StoredValue = this.NameListenerData;

function StoredValue = LocalGetSelectedListenerValue(this,StoredValue)
if isempty(this.SelectedListenerData)
    this.SelectedListenerData = controllibutils.ListenerManager;
end
StoredValue = this.SelectedListenerData;

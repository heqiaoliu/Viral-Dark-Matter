function schema
%SCHEMA  Definition of @plot interface (part of @wrfc foundation package).

%  Author(s): P. Gahinet
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:37:57 $

% Find parent package
pkg = findpackage('wrfc');

% Register class 
c = schema.class(pkg, 'plot');

% Class attributes
schema.prop(c, 'AxesGrid',  'handle');         % Plot axes (@axesgrid)
schema.prop(c, 'BackgroundLines',  'MATLAB array');   % BackgroundLines lines
p = schema.prop(c, 'DataExceptionWarning', 'on/off'); % Enable/disables warning for data exceptions
p.FactoryValue = 'on';
schema.prop(c, 'Options', 'MATLAB array');      % Plot Options (char + plot)
schema.prop(c, 'StyleManager', 'handle');      % Style manager 
schema.prop(c, 'Visible',    'on/off');        % Response plot visibility
schema.prop(c, 'Tag', 'string');               % Plot tag (identifier for FIND)
schema.prop(c, 'SaveData', 'MATLAB array');    % Presave data used during figure saves
p = schema.prop(c, 'CharacteristicManager', 'MATLAB array');    % Characteristics manager
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'off');


% Private attributes
p = schema.prop(c, 'ListenersData', 'MATLAB array'); % ListenerManager Class
p = schema.prop(c, 'Listeners', 'MATLAB array');     % Virtual property ListenerManager Class
p.GetFunction = @LocalGetListenersValue;
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off',...
   'AccessFlags.PrivateSet', 'off','AccessFlags.Serialize','off');
%Property to store requirements displayed by the plot
p = schema.prop(c, 'Requirements', 'MATLAB array');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off',...
   'AccessFlags.Serialize','off');

% Event
schema.event(c,'RequirementAdded');


function StoredValue = LocalGetListenersValue(this,StoredValue)
if isempty(this.ListenersData)
    this.ListenersData = controllibutils.ListenerManager;
end
StoredValue = this.ListenersData;
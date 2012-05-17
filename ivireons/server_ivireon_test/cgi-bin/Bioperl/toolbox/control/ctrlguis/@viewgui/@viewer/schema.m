function schema
%  SCHEMA  Defines properties for @viewer class

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.13.4.3 $  $Date: 2010/04/21 21:10:47 $

MaxNumberViews = 6;

% Register class
c = schema.class(findpackage('viewgui'), 'viewer');
c.Description = 'Generic class with attributes for building a viewer.';

%%%%%%%%%%%%%%%%%%%%
% Class attributes
%%%%%%%%%%%%%%%%%%%
% Struct Array of available views
p = schema.prop(c, 'AvailableViews',    'MATLAB array');  
p.FactoryValue = struct('Name',cell(0,1),'Alias',[],'CreateFcn',[]);
p.Description = 'All available view types with the recipe for creating them.';

% Event manager
p = schema.prop(c,'EventManager','handle');         
p.Description = 'Event coordinator (@framemgr object)';

% Handle to the host Figure
p = schema.prop(c, 'Figure', 'MATLAB array');               
p.SetFunction = @LocalConvertToHandle;

p  = schema.prop(c, 'Preferences',  'handle');         % Viewer Preferences
p.Description = 'Viewer preferences.';

p  = schema.prop(c, 'StyleManager', 'handle');  % StyleManager
p.Description = 'Style manager.';

% REVISIT: handle(NaN) not accepted for 'handle vector' type
%p = schema.prop(c, 'Views', 'handle vector');  % Plot
p = schema.prop(c, 'Views', 'MATLAB array');  % Plot
p.FactoryValue = repmat(handle(NaN),MaxNumberViews,1);
p.SetFunction = @LocalSetViews;
p.Description = 'Vector of all @plot handles.';

% Event
%%%%%%%
% Change in plot configuration (issued when this.Views or view visibility
% changes)
schema.event(c,'ConfigurationChanged');  

% Private attributes
%%%%%%%%%%%%%%%%%%%%%%
% HG objects - Figure Menu, Status Bar etc.(struct)
p = schema.prop(c, 'HG', 'MATLAB array');
p.AccessFlags.PublicSet ='off';

% View stacks for each plot cell
p = schema.prop(c, 'PlotCells', 'MATLAB array');
%p.AccessFlags.PublicGet = 'off';
%p.AccessFlags.PublicSet = 'off';
p.FactoryValue = repmat({handle(zeros(0,1))},MaxNumberViews,1);

p = schema.prop(c, 'ListenersData', 'MATLAB array'); % ListenerManager Class
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize= 'off';
p = schema.prop(c, 'Listeners', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.GetFunction = @LocalGetListenersValue;


%%%%%%%%%%%%%%%%%
% LocalSetViews %
%%%%%%%%%%%%%%%%%
function NewViews = LocalSetViews(this, NewViews)
% Sets the Current Views based on the visibility of the Views in the Viewer
if ~isempty(this.Views) && length(NewViews)~=length(this.Views)
   ctrlMsgUtils.error('Control:viewer:ViewsProperty', length(this.Views))
end


function StoredValue = LocalGetListenersValue(this,StoredValue)
if isempty(this.ListenersData)
    this.ListenersData = controllibutils.ListenerManager;
end
StoredValue = this.ListenersData;

function Value = LocalConvertToHandle(this,Value)
% Converts to handle
Value = handle(Value);
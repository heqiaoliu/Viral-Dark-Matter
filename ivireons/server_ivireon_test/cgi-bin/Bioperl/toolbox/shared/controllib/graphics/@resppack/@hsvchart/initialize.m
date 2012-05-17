function initialize(this)
%INITIALIZE  Initializes @hsvchart instance.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:49 $

% Concrete Factory Method to create adequate @data and @view objects
[this.Data, this.View, DataProps] = createdataview(this.Parent,1);

% Initialize @view objects
initialize(this.View,getaxes(this))

% Install listeners (generic + @hsvchart-specific)
addlisteners(this)

% Install listener to data changes
% RE: Can be switched off to avoid excessive traffic when clear all data
%     in waveform array
L = handle.listener(this.Data, DataProps,'PropertyPostSet', @(x,y) LocalNotify(this,y));
this.DataChangedListener = L;
   
% Initialize (effective) visibility of HG objects
refresh(this)


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Notify peers of change in wave data (this = @hsvchart object)
% ----------------------------------------------------------------------------%
function LocalNotify(this, eventdata)
if ~isempty(eventdata.NewValue)
  % REVISIT: simplify when send(event, data) supported
  this.send('DataChanged', ctrluis.dataevent(this, 'DataChanged', 1));
end



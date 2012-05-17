function updateactions(h)
%UPDATEACTIONS   Update the UI Actions (callbacks)

%   Author(s): P. Costa
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/09/09 21:07:31 $

ActRun = h.getresults(0);
RefRun = h.getresults(1);
ActHasData  = ~isempty(ActRun);
RefHasData  = ~isempty(RefRun);

% Get the Actions that we are interested in controlling the enable state
% sarAction = me.getaction('RESULTS_SHOWACTIVERUN');
% srrAction = me.getaction('RESULTS_SHOWREFRUN');

if (~ActHasData && ~RefHasData)
  h.getaction('RESULTS_STOREACTIVERUN').Enabled = 'off';
  h.getaction('RESULTS_STOREREFRUN').Enabled = 'off';
  h.getaction('RESULTS_CLEARACTIVERUN').Enabled = 'off';
  h.getaction('RESULTS_CLEARREFRUN').Enabled = 'off';
  h.getaction('VIEW_TSINFIGURE').Enabled = 'off';
  h.getaction('VIEW_HISTINFIGURE').Enabled = 'off';
  h.getaction('VIEW_DIFFINFIGURE').Enabled = 'off';
  h.getaction('VIEW_AUTOSCALEINFO').Enabled = 'off';
  h.getaction('HILITE_BLOCK').Enabled = 'off';
  h.getaction('HILITE_CONNECTED_BLOCKS').Enabled = 'off';
  h.getaction('HILITE_DTGROUP').Enabled = 'off';
  h.getaction('SCALE_PROPOSE').Enabled = 'on';
  h.getaction('SCALE_APPLY').Enabled = 'on';
  h.getaction('START').Enabled = 'on';
  h.getaction('PAUSE').Enabled = 'off';
  h.getaction('STOP').Enabled = 'off';
elseif (ActHasData && ~RefHasData)
  h.getaction('RESULTS_STOREACTIVERUN').Enabled = 'on';
  h.getaction('RESULTS_STOREREFRUN').Enabled = 'off';
  h.getaction('RESULTS_CLEARACTIVERUN').Enabled = 'on';
  h.getaction('RESULTS_CLEARREFRUN').Enabled = 'off';
  h.getaction('VIEW_TSINFIGURE').Enabled = 'on';
  h.getaction('VIEW_HISTINFIGURE').Enabled = 'on';
  h.getaction('VIEW_DIFFINFIGURE').Enabled = 'on';
  h.getaction('VIEW_AUTOSCALEINFO').Enabled = 'on';
  h.getaction('HILITE_BLOCK').Enabled = 'on';
  h.getaction('HILITE_CONNECTED_BLOCKS').Enabled = 'on';
  h.getaction('HILITE_DTGROUP').Enabled = 'on';
  h.getaction('SCALE_PROPOSE').Enabled = 'on';
  h.getaction('SCALE_APPLY').Enabled = 'on';
  h.getaction('START').Enabled = 'on';
  h.getaction('PAUSE').Enabled = 'off';
  h.getaction('STOP').Enabled = 'off';
elseif(~ActHasData && RefHasData)
  h.getaction('RESULTS_STOREACTIVERUN').Enabled = 'off';
  h.getaction('RESULTS_STOREREFRUN').Enabled = 'on';
  h.getaction('RESULTS_CLEARACTIVERUN').Enabled = 'off';
  h.getaction('RESULTS_CLEARREFRUN').Enabled = 'on';
  h.getaction('VIEW_TSINFIGURE').Enabled = 'on';
  h.getaction('VIEW_HISTINFIGURE').Enabled = 'on';
  h.getaction('VIEW_DIFFINFIGURE').Enabled = 'on';
  h.getaction('VIEW_AUTOSCALEINFO').Enabled = 'on';
  h.getaction('HILITE_BLOCK').Enabled = 'on';
  h.getaction('HILITE_CONNECTED_BLOCKS').Enabled = 'on';
  h.getaction('HILITE_DTGROUP').Enabled = 'on';
  h.getaction('SCALE_PROPOSE').Enabled = 'on';
  h.getaction('SCALE_APPLY').Enabled = 'on';
  h.getaction('START').Enabled = 'on';
  h.getaction('PAUSE').Enabled = 'off';
  h.getaction('STOP').Enabled = 'off';
elseif (ActHasData && RefHasData)
  h.getaction('RESULTS_STOREACTIVERUN').Enabled = 'on';
  h.getaction('RESULTS_STOREREFRUN').Enabled = 'on';
  h.getaction('RESULTS_CLEARACTIVERUN').Enabled = 'on';
  h.getaction('RESULTS_CLEARREFRUN').Enabled = 'on';
  h.getaction('VIEW_TSINFIGURE').Enabled = 'on';
  h.getaction('VIEW_HISTINFIGURE').Enabled = 'on';
  h.getaction('VIEW_DIFFINFIGURE').Enabled = 'on';
  h.getaction('VIEW_AUTOSCALEINFO').Enabled = 'on';
  h.getaction('HILITE_BLOCK').Enabled = 'on';
  h.getaction('HILITE_CONNECTED_BLOCKS').Enabled = 'on';
  h.getaction('HILITE_DTGROUP').Enabled = 'on';  
  h.getaction('SCALE_PROPOSE').Enabled = 'on';
  h.getaction('SCALE_APPLY').Enabled = 'on';
  h.getaction('START').Enabled = 'on';
  h.getaction('PAUSE').Enabled = 'off';
  h.getaction('STOP').Enabled = 'off';
end
h.getaction('HILITE_CLEAR').Enabled = 'on';
h.getaction('RESULTS_SWAPRUNS').Enabled = 'on';  
%widgets need to update their enabledness depending on the enabledness of
%certain actions. Firing a property change reloads the dialog.
node = h.imme.getCurrentTreeNode;
if(isa(node, 'fxptui.subsysnode'))
  node.firepropertychange;
end

% [EOF]

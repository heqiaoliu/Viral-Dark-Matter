function h = DiagViewer(name)
% DIAGVIEWER
% Constructs an instance of the Diagnostic Viewer.
%   
% A Diagnostic Viewer (DV) displays messages in a window based on the Model
% Explorer. It is designed to work with Simulink's nag (error and warning
% message) controller (slsfnagctlr). 
% 
%  Usage:
%
%    dv = DAStudio.DiagView(); % Creates a dv instance.
%    dv.convertNagsToUDD(nags) % Populates dv with nags.
%    dv.Visible = true;        % Makes dv visible.
%    dv.flushMsgs;             % Clears nags from viewer.
%    dv.Visible = false;       % Hides dv.
%
%  Copyright 2008 The MathWorks, Inc. 

 h = DAStudio.DiagViewer;
 
 % Connect this instance to the DAStudio's UDD object hierarchy.
 rt = DAStudio.Root;
 connect(rt, h, 'down');
 
 % Install listener for changes to the DV's Visible property.
 % The listener makes the DV visible or invisible depending
 % on the setting of the Visible property.
 h.installVisibleListener;
 
 % Set the DV's name property. This allows identification of different
 % instances of the Diagnostic Viewer.
 h.Name = name;
 
 % Set window title initially to be same as the name of this DV instance.
 h.Title = h.Name;
 
 % Create a null message to appear in the dialog pane of the DV's
 % Explorer instance when there are no messages to display.
 
 h.NullMessage = h.createNullMsg();
 
 % Specify order of message properties to be displayed initially
 % in the DV's list view.
 h.msgListPropsOrder = {'DispType' 'SourceName' 'Component' 'Summary'};
 
 % Specify message properties to be displayed initially
 % in the DV's list view. 
 h.msgListProps = {'DispType' 'SourceName' 'Component' 'Summary'};

 
end
function Frame = clview(sisodb)
% Creates and manages the closed-loop pole view.

%   Authors:  Bora Eryilmaz
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.19.4.7 $ $Date: 2010/04/30 00:37:06 $
 
% Import Java packages
import com.mathworks.mwt.*;
import java.awt.*;

% GUI data structure
s = struct(...
    'LoopData', sisodb.LoopData, ...
    'Preferences', cstprefs.tbxprefs, ...
    'sPreferences', sisodb.Preferences, ...
    'Table', [], ...
    'ComboBox', [], ...
    'CurrentList', [], ...
    'Currentidx', [], ...
    'Handles', [], ...
    'Listeners', []);

% Create main Frame
Frame = MWFrame(sprintf('Closed-Loop Pole Viewer'));
Frame.setLayout(MWBorderLayout(0,0));
Frame.setFont(s.Preferences.JavaFontP);
Frame.setResizable(false);

% Main panel
MainPanel = MWPanel(MWBorderLayout(0,0));
MainPanel.setInsets(Insets(10,5,5,5));
Frame.add(MainPanel, MWBorderLayout.CENTER);
s.Handles = {MainPanel};

% Add list and button panels
[ListPanel, s]     = LocalAddList(Frame, s);
[ButtonPanel, s  ] = LocalAddButton(Frame, s);
MainPanel.add(ListPanel,     MWBorderLayout.CENTER);
MainPanel.add(ButtonPanel,   MWBorderLayout.SOUTH);

% Layout the frame
Frame.pack;

% Center wrt SISO Tool window
centerfig(Frame, sisodb.Figure);

% Install listeners
lsnr(1) = handle.listener(s.LoopData, ...
	  'ObjectBeingDestroyed', @(x,y) LocalClose(Frame));
lsnr(2) = handle.listener(s.LoopData, ...
	  'LoopDataChanged', @(x,y) LocalRefresh(Frame));
p = findprop(s.sPreferences, 'FrequencyUnits');
lsnr(3) = handle.listener(s.sPreferences, p, ...
			  'PropertyPostSet', @(x,y) LocalRefresh(Frame));
lsnr(4) = handle.listener(s.LoopData, ...
      'ConfigChanged', @(x,y) LocalConfigChange(Frame));
s.Listeners = lsnr;

% Set callbacks and store handles 
set(Frame, 'UserData', s);
hc = handle(Frame, 'callbackproperties');
set(hc,'WindowClosingCallback',@(x,y) LocalHide(Frame));

LocalConfigChange(Frame);  % Initialize and populate to limit flashing

% Make frame visible
Frame.show;
Frame.toFront;


% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalHide
% Purpose:  Hide dialog Frame
% ----------------------------------------------------------------------------%
function LocalHide(f)
f.hide;

% ----------------------------------------------------------------------------%
% Function: LocalClose
% Purpose:  Destroy dialog Frame
% ----------------------------------------------------------------------------%
function LocalClose(f)
f.hide;
f.dispose;

% ----------------------------------------------------------------------------%
% Function: LocalConfigChange
% Purpose:  Refresh the feedback list and content of the list (closed-loop pole info)
% ----------------------------------------------------------------------------%
function LocalConfigChange(Frame)
import javax.swing.*;

s = get(Frame, 'UserData');

% Get list of compenstators for feedback = true
booFeedbackList = get(s.LoopData.L,{'Feedback'});

Newidx=find([booFeedbackList{:}]==true);
LoopList = get(s.LoopData.L,{'Identifier'});
NewList = LoopList(Newidx);

s.ComboBox.setModel(DefaultComboBoxModel(NewList));
s.CurrentList = NewList;
s.Currentidx = Newidx;

set(Frame, 'UserData', s)

LocalRefresh(Frame);


% ----------------------------------------------------------------------------%
% Function: LocalRefresh
% Purpose:  Refresh the content of the list (closed-loop pole info)
% ----------------------------------------------------------------------------%
function LocalRefresh(Frame)
import javax.swing.*;

s = get(Frame, 'UserData');
if ~isa(s.LoopData, 'sisodata.loopdata')
  % Protect against race condition when SISO Tool is closed
  return
end


% Get Selected index to display
Selectedidx = s.Currentidx(s.ComboBox.getSelectedIndex+1);

% Get closed-loop poles
OL = getOpenLoop(s.LoopData.L(Selectedidx)); % zpkdata
if isempty(OL)
   P = [];
else
   if isproper(OL)
      [a,b,c,d] = getABCD(ss(OL));
   else
      [a,b,c,d] = getABCD(ss(inv(OL)));
   end
   P = genrloc(a,b,c,d,1,[],[]);
end

% Group the Poles into real and complex values
im = imag(P);
P = [P(~im,:) ; P(im>0,:)];

% Add text for pole data
if isempty(P)
  PoleText = cell(1,3);
  PoleText(1,1) = {sprintf('<None>')};
else
  % Natural frequencies )in current units) and damping ratios
  [Wn, Z] = damp(P, s.LoopData.Ts);
  Wn = unitconv(Wn, 'rad/sec', s.sPreferences.FrequencyUnits);
  PoleText = cell(length(P), 3);
  
  % Populate the list
  for ct = 1:length(P),
    rP = real(P(ct));
    iP = imag(P(ct));
    if iP
      PoleText(ct,1) = {sprintf('%0.3g +/- %0.3gi', rP, iP)};
    else
      PoleText(ct,1) = {sprintf('%0.3g', rP)};
    end
    PoleText(ct,2) = {sprintf('%0.3g', Z(ct))};
    PoleText(ct,3) = {sprintf('%0.3g', Wn(ct))};
  end
end

% Adjust table size
Table = s.Table;
TData = Table.getData;
nrows = Table.getTableSize.height;
npoles = length(P);
if (npoles > nrows)
  TData.addRows(nrows, npoles-nrows);
elseif (npoles<nrows) && (npoles>=10)
  % REM: Magic number 10: initial number of rows
  TData.removeRows(npoles, nrows-npoles);
end

% Update table content
minrows = max(1, npoles); % if npoles = 0, display <none> for no poles.
for ctcol = 1:3,
  for ctrow = 1:minrows 
    TData.setData(ctrow-1, ctcol-1, PoleText{ctrow,ctcol});
  end
  for ctrow = minrows+1:Table.getTableSize.height
    TData.setData(ctrow-1, ctcol-1, '');
  end
end

% Store modified data
set(Frame, 'UserData', s)


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalAddButton
% Purpose:  Adds Close button (and Help if needed)
% ----------------------------------------------------------------------------%
function [Panel, s] = LocalAddButton(Frame, s)
import com.mathworks.mwt.*;
import java.awt.*;

% Button panel
Panel = MWPanel(FlowLayout);

% Close button
closeButton = MWButton(sprintf('Close'));  
closeButton.setFont(s.Preferences.JavaFontP);
hc = handle(closeButton, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(x,y) LocalHide(Frame));



% Help button
% helpButton = MWButton(sprintf('Help'));       
% helpButton.setFont(s.Preferences.JavaFontP);
% set(helpButton, 'ActionPerformedCallback', ...
%         	'ctrlguihelp(''sisoclosedpoleview'');')

% Connect components
Panel.add(closeButton);
% Panel.add(helpButton);

% Store handle for persistency
% s.Handles = [s.Handles ; {Panel;cancelButton;helpButton}];
s.Handles = [s.Handles ; {Panel;closeButton}];


% ----------------------------------------------------------------------------%
% Function: LocalAddList
% Purpose:  Adds closed-loop poles list to the List panel
% ----------------------------------------------------------------------------%
function [Panel, s] = LocalAddList(Frame, s)
import com.mathworks.mwt.*;
import java.awt.*;
import javax.swing.*;

% Main panel
Panel = MWGroupbox(sprintf('Closed-Loop Poles'));
Panel.setLayout(MWBorderLayout(0,5));
Panel.setFont(s.Preferences.JavaFontB);

% Table view
Table = MWTable(10,3);
Table.setPreferredTableSize(8,4);
Table.getTableStyle.setFont(s.Preferences.JavaFontP);
Table.getColumnOptions.setResizable(1);
Table.getHScrollbarOptions.setMode(-1);

% Table style parameters
Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));

% First column
Table.setColumnStyle(0, Cstyle);
Table.setColumnWidth(0, 100);
Table.setColumnHeaderData(0, sprintf('Pole Value'));

% Second column
Table.setColumnStyle(1, Cstyle);
Table.setColumnWidth(1, 100);
Table.setColumnHeaderData(1, sprintf('Damping'));

% Third column
Table.setColumnStyle(2, Cstyle);
Table.setColumnWidth(2, 100);
Table.setColumnHeaderData(2, sprintf('Frequency'));

Table.setAutoExpandColumn(0);
Table.getRowOptions.setHeaderVisible(0);
Table.getSelectionOptions.setMode(0);      % none

% Create ComboBox
ComboBoxPanel = JPanel(BorderLayout);
ComboBoxLabel = JLabel(xlate('Select Feedback Loop: '));
ComboBox = JComboBox;
ComboBoxPanel.add(ComboBoxLabel,BorderLayout.WEST);
ComboBoxPanel.add(ComboBox, BorderLayout.CENTER);
hc = handle(ComboBox, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(x,y) LocalRefresh(Frame));


% Connect components
Panel.add(Table, MWBorderLayout.CENTER);
Panel.add(ComboBoxPanel, MWBorderLayout.NORTH);
% Store handle for persistency
s.Table = Table;
s.ComboBox = ComboBox;
s.Handles = [s.Handles ; {Panel}];

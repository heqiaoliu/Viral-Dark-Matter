function Main = grid_gui(h)
%GRID_GUI  GUI for editing grid properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2010/04/21 21:10:41 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Controllib:gui:strGrids'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);
   
%---Checkbox to toggle grid visibility
s.Grid = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strShowGridsLabel'));
s.Grid.setFont(Prefs.JavaFontP);
Main.add(s.Grid,com.mathworks.mwt.MWBorderLayout.WEST);

%---Install listeners and callbacks
s.GridListener = handle.listener(h,findprop(h,'Grid'),'PropertyPostSet',{@localReadProp,s.Grid});
s.Grid.setName('Grid');
hc = handle(s.Grid, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,GUI)
% Update GUI when property changes
GUI.setState(strcmpi(eventData.NewValue,'on'));


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% Update property when GUI changes
if eventSrc.getState
    h.Grid = 'on';
else
    h.Grid = 'off';
end

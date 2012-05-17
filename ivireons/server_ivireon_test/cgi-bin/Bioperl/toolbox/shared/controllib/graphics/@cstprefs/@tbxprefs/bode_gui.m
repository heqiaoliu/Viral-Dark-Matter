function Main = bode_gui(h)
%BODE_GUI  GUI for editing Siso Tool Bode options of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:45:02 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Controllib:gui:strBodeOptions'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);
   
%---Checkbox to toggle system pole/zero visibility
s.ShowSystemPZ = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strShowPlantPolesZeros'));
s.ShowSystemPZ.setFont(Prefs.JavaFontP);
Main.add(s.ShowSystemPZ,com.mathworks.mwt.MWBorderLayout.WEST);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'tbxprefs');
s.ShowSystemPZListener = handle.listener(h,CLS.findprop('ShowSystemPZ'),'PropertyPostSet',{@localReadProp,s.ShowSystemPZ});
s.ShowSystemPZ.setName('ShowSystemPZ');
hc = handle( s.ShowSystemPZ, 'callbackproperties');
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
    h.ShowSystemPZ = 'on';
else
    h.ShowSystemPZ = 'off';
end
    

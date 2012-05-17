function Main = wrap_gui(h)
%WRAP_GUI  GUI for editing phase wrap properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:45:23 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWPanel;
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Checkbox
s.UnwrapPhase = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strUnwrapPhase'));
s.UnwrapPhase.setState(strcmpi(Prefs.UnwrapPhase,'on'));
s.UnwrapPhase.setFont(Prefs.JavaFontP);
Main.add(s.UnwrapPhase,com.mathworks.mwt.MWBorderLayout.WEST);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'viewprefs');
s.UnwrapPhaseListener = handle.listener(h,CLS.findprop('UnwrapPhase'),'PropertyPostSet',{@localReadProp,s.UnwrapPhase});
set(s.UnwrapPhase,'Name','UnwrapPhase');
UnwrapPhaseCheckBox = handle( s.UnwrapPhase, 'callbackproperties' );
UnwrapPhaseCheckBox.ItemStateChangedCallback = {@localWriteProp,h};

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
    h.UnwrapPhase = 'on';
else
    h.UnwrapPhase = 'off';
end
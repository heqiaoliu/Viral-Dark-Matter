function Main = mingain_gui(h)
%MINGAIN_GUI  GUI for editing min gain properties of h

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:45:10 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWPanel;
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Checkbox
s.MGPanel = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,1));
s.MinGainBox = com.mathworks.mwt.MWCheckbox(sprintf('%s  ',...
    ctrlMsgUtils.message('Controllib:gui:strMinGainLabel')));
s.MinGainBox.setState(strcmpi(Prefs.MinGainLimit.Enable,'on'));
s.MinGainBox.setFont(Prefs.JavaFontP);
s.MGPanel.add(s.MinGainBox);
s.MinGainEdit = com.mathworks.mwt.MWTextField(sprintf('%.3f',0),7);
LocalEnableMinGain(s,strcmp(s.MinGainBox.getState,'on'))
s.MGPanel.add(s.MinGainEdit);


Main.add(s.MGPanel,com.mathworks.mwt.MWBorderLayout.WEST);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'tbxprefs');
s.MinGainListener = [handle.listener(h,CLS.findprop('MinGainLimit'),'PropertyPostSet',{@localReadProp,s}); ...
    handle.listener(h,findprop(Prefs,'MagnitudeUnits'),'PropertyPreSet',{@LocalMagUnitsChanged s, h})];
s.MinGainBox.setName('MinGainBox');
hc = handle(s.MinGainBox, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h,s));
s.MinGainEdit.setName('MinGainEdit');
hc = handle(s.MinGainEdit, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) LocalWriteMinGain(es,ed,h));
set(hc,'FocusLostCallback',@(es,ed) LocalWriteMinGain(es,ed,h));


%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,GUI)
% Update GUI when property changes
GUI.MinGainBox.setState(strcmpi(eventData.NewValue.Enable,'on'));
GUI.MinGainEdit.setText(sprintf('%.3f',eventData.NewValue.MinGain))
LocalEnableMinGain(GUI,strcmpi(eventData.NewValue.Enable,'on'))

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,s)
% Update property when GUI changes
if eventSrc.getState
    h.MinGainLimit.Enable = 'on';
else
    h.MinGainLimit.Enable = 'off';
end


LocalEnableMinGain(s,strcmp(h.MinGainLimit.Enable,'on'))

%%%%%%%%%%%%%%%%%%
% localWriteMinGain %
%%%%%%%%%%%%%%%%%%
function LocalWriteMinGain(eventSrc,eventData,h)
% Update property when GUI changes
NewValue = str2num(char(eventSrc.getText));
if ~isempty(NewValue) && isnumeric(NewValue) && isscalar(NewValue) && isfinite(NewValue)
    h.MinGainLimit.MinGain = double(full(NewValue));
else
    eventSrc.setText(sprintf('%.3f',h.MinGainLimit.MinGain));
end


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalMagUnitsChanged %
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMagUnitsChanged(eventSrc,eventData,GUI, h)
% Get old and new mag units
OldMagUnits = eventData.AffectedObject.MagnitudeUnits;
NewMagUnits = eventData.NewValue;

% Update min gain
NewMag = unitconv(str2num(char(GUI.MinGainEdit.getText)),OldMagUnits,NewMagUnits);
GUI.MinGainEdit.setText(sprintf('%.3f',NewMag))

if GUI.MinGainBox.getState
    MinGainBoxState = 'on';
else
    MinGainBoxState = 'off';
end

h.MinGainLimit = struct('Enable', MinGainBoxState,'MinGain',NewMag);

%%%%%%%%%%%%%%%%%%%%%%
% LocalEnableMinGain %
%%%%%%%%%%%%%%%%%%%%%%
function LocalEnableMinGain(s,enstate)
% Enable Disable Fields
s.MinGainEdit.setEnabled(enstate);
s.MinGainEdit.repaint;








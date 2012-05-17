function Main = unit_gui(h)
%UNIT_GUI  GUI for editing unit & scale properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2010/04/21 21:10:44 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
FL_L  = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,8,0);
GL_12 = java.awt.GridLayout(1,2,8,0);
GL_31 = java.awt.GridLayout(3,1,0,3);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Controllib:gui:strUnits'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Units panel (west)
s.Units = com.mathworks.mwt.MWPanel(GL_31); Main.add(s.Units,com.mathworks.mwt.MWBorderLayout.WEST);
   %---Frequency units
    s.FrequencyUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.FrequencyUnitsPanel);
    s.FrequencyUnitsLabel = com.mathworks.mwt.MWLabel(ctrlMsgUtils.message('Controllib:gui:strFrequencyInLabel')); 
    s.FrequencyUnitsPanel.add(s.FrequencyUnitsLabel);
    s.FrequencyUnits = com.mathworks.mwt.MWChoice; s.FrequencyUnitsPanel.add(s.FrequencyUnits);
    s.FrequencyUnits.add(ctrlMsgUtils.message('Controllib:gui:strHz')); 
    s.FrequencyUnits.add(ctrlMsgUtils.message('Controllib:gui:strRadPerSec'));
    s.FrequencyUnitsLabel.setFont(Prefs.JavaFontP);
    s.FrequencyUnits.setFont(Prefs.JavaFontP);
   %---Magnitude units
    s.MagnitudeUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.MagnitudeUnitsPanel);
    s.MagnitudeUnitsLabel = com.mathworks.mwt.MWLabel(ctrlMsgUtils.message('Controllib:gui:strMagnitudeInLabel')); 
    s.MagnitudeUnitsPanel.add(s.MagnitudeUnitsLabel);
    s.MagnitudeUnits = com.mathworks.mwt.MWChoice; s.MagnitudeUnitsPanel.add(s.MagnitudeUnits);
    s.MagnitudeUnits.add(ctrlMsgUtils.message('Controllib:gui:strDB')); 
    s.MagnitudeUnits.add(ctrlMsgUtils.message('Controllib:gui:strAbsolute'));
    s.MagnitudeUnitsLabel.setFont(Prefs.JavaFontP);
    s.MagnitudeUnits.setFont(Prefs.JavaFontP);
   %---Phase units
    s.PhaseUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.PhaseUnitsPanel);
    s.PhaseUnitsLabel = com.mathworks.mwt.MWLabel(ctrlMsgUtils.message('Controllib:gui:strPhaseInLabel')); 
    s.PhaseUnitsPanel.add(s.PhaseUnitsLabel);
    s.PhaseUnits = com.mathworks.mwt.MWChoice; s.PhaseUnitsPanel.add(s.PhaseUnits);
    s.PhaseUnits.add(ctrlMsgUtils.message('Controllib:gui:strDegrees')); 
    s.PhaseUnits.add(ctrlMsgUtils.message('Controllib:gui:strRadians'));
    s.PhaseUnitsLabel.setFont(Prefs.JavaFontP);
    s.PhaseUnits.setFont(Prefs.JavaFontP);

%---Scale panel (center)
s.Scale = com.mathworks.mwt.MWPanel(GL_31); Main.add(s.Scale,com.mathworks.mwt.MWBorderLayout.CENTER);
   %---Frequency scale
    s.FrequencyScalePanel = com.mathworks.mwt.MWPanel(FL_L); s.Scale.add(s.FrequencyScalePanel);
    s.FrequencyScaleLabel = com.mathworks.mwt.MWLabel(ctrlMsgUtils.message('Controllib:gui:strUsing')); 
    s.FrequencyScalePanel.add(s.FrequencyScaleLabel);
    s.FrequencyScale = com.mathworks.mwt.MWChoice; s.FrequencyScalePanel.add(s.FrequencyScale);
    s.FrequencyScale.add(ctrlMsgUtils.message('Controllib:gui:strLinearScale')); 
    s.FrequencyScale.add(ctrlMsgUtils.message('Controllib:gui:strLogScale'));
    s.FrequencyScaleLabel.setFont(Prefs.JavaFontP);
    s.FrequencyScale.setFont(Prefs.JavaFontP);
   %---Magnitude scale
    s.MagnitudeScalePanel = com.mathworks.mwt.MWPanel(FL_L); s.Scale.add(s.MagnitudeScalePanel);
    s.MagnitudeScaleLabel = com.mathworks.mwt.MWLabel(ctrlMsgUtils.message('Controllib:gui:strUsing')); 
    s.MagnitudeScalePanel.add(s.MagnitudeScaleLabel);
    s.MagnitudeScale = com.mathworks.mwt.MWChoice; s.MagnitudeScalePanel.add(s.MagnitudeScale);
    s.MagnitudeScale.add(ctrlMsgUtils.message('Controllib:gui:strLinearScale')); 
    s.MagnitudeScale.add(ctrlMsgUtils.message('Controllib:gui:strLogScale'));
    s.MagnitudeScaleLabel.setFont(Prefs.JavaFontP);
    s.MagnitudeScale.setFont(Prefs.JavaFontP);

%---Install listeners and callbacks
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h};
   %---Frequency Units
    s.FrequencyUnitsListener = handle.listener(h,findprop(h,'FrequencyUnits'),'PropertyPostSet',Callback);
    s.FrequencyUnits.setName('FrequencyUnits');
    hc = handle(s.FrequencyUnits, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));
   %---Magnitude Units
    s.MagnitudeUnitsListener = handle.listener(h,findprop(h,'MagnitudeUnits'),'PropertyPostSet',Callback);
    s.MagnitudeUnits.setName('MagnitudeUnits');
    hc = handle(s.MagnitudeUnits, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));
   %---Phase Units
    s.PhaseUnitsListener = handle.listener(h,findprop(h,'PhaseUnits'),'PropertyPostSet',Callback);
    s.PhaseUnits.setName('PhaseUnits');
    hc = handle(s.PhaseUnits, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));
   %---Frequency Scale
    s.FrequencyScaleListener = handle.listener(h,findprop(h,'FrequencyScale'),'PropertyPostSet',Callback);
    s.FrequencyScale.setName('FrequencyScale');
    hc = handle(s.FrequencyScale, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));
   %---Magnitude Scale
    s.MagnitudeScaleListener = handle.listener(h,findprop(h,'MagnitudeScale'),'PropertyPostSet',Callback);
    s.MagnitudeScale.setName('MagnitudeScale');
    hc = handle(s.MagnitudeScale, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Update GUI when property changes
Name = eventSrc.Name;
NewValue = eventData.NewValue;
%---Set GUI state
switch Name
case 'FrequencyUnits'
   if strcmpi(eventData.NewValue(1),'h')
      s.FrequencyUnits.select(0);
   else
      s.FrequencyUnits.select(1);
   end
case 'MagnitudeUnits'
   h = eventData.AffectedObject;
   if strcmpi(eventData.NewValue(1),'d')
      s.MagnitudeUnits.select(0);
      awtinvoke(s.MagnitudeScalePanel,'setVisible(Z)',false);
      h.MagnitudeScale = 'linear';
   else
      s.MagnitudeUnits.select(1);
      h.MagnitudeScale = 'linear';
      awtinvoke(s.MagnitudeScalePanel,'setVisible(Z)',true);
   end
case 'PhaseUnits'
   if strcmpi(eventData.NewValue(1),'d')
      s.PhaseUnits.select(0);
   else
      s.PhaseUnits.select(1);
   end
case 'FrequencyScale'
   if strcmpi(eventData.NewValue,'linear')
      s.FrequencyScale.select(0);
   else
      s.FrequencyScale.select(1);
   end
case 'MagnitudeScale'
   if strcmpi(eventData.NewValue,'linear')
      s.MagnitudeScale.select(0);
   else
      s.MagnitudeScale.select(1);
   end
end

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% Update property when GUI changes
Name = char(eventSrc.getName);
switch Name
case {'FrequencyUnits'}
   if eventSrc.getSelectedIndex==0
      Value = 'Hz';
   else
      Value = 'rad/sec';
   end
case {'MagnitudeUnits'}
   if eventSrc.getSelectedIndex==0
      Value = 'dB';
   else
      Value = 'abs';
   end
case {'PhaseUnits'}
   if eventSrc.getSelectedIndex==0
      Value = 'deg';
   else
      Value = 'rad';
   end
case {'FrequencyScale','MagnitudeScale'}
   if eventSrc.getSelectedIndex==0
      Value = 'linear';
   else
      Value = 'log';
   end
end
set(h,Name,Value);

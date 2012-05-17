function Main = font_gui(h)
%FONT_GUI  GUI for editing font properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2010/04/21 21:10:40 $ 

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Controllib:gui:strFonts'));
Main.setLayout(java.awt.GridLayout(3,1,0,3));
Main.setFont(Prefs.JavaFontB);

%---Add a font panel for each text group
s.Row1 = localFontPanel('Title',ctrlMsgUtils.message('Controllib:gui:strTitlesLabel'), h);  
Main.add(s.Row1);
s.Row2 = localFontPanel('XYLabels',ctrlMsgUtils.message('Controllib:gui:strXYLabel'), h);  
Main.add(s.Row2);
s.Row3 = localFontPanel('Axes',ctrlMsgUtils.message('Controllib:gui:strTickLabelsLabel'),h);  
Main.add(s.Row3);


%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%%
% localFontPanel %
%%%%%%%%%%%%%%%%%%
function Panel = localFontPanel(PropName,Label,h)
% Create a java panel for editing font properties

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Build GUI
Panel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0));
Panel.setFont(java.awt.Font('Dialog',java.awt.Font.PLAIN,12));
s.Label = com.mathworks.mwt.MWLabel(sprintf('%s',Label),com.mathworks.mwt.MWLabel.LEFT);
   s.Label.setFont(Prefs.JavaFontP);
   Panel.add(s.Label,com.mathworks.mwt.MWBorderLayout.WEST);
s.East = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,15,0));
   Panel.add(s.East,com.mathworks.mwt.MWBorderLayout.EAST);
   s.Size = com.mathworks.mwt.MWChoice; s.East.add(s.Size);
   s.Size.setFont(Prefs.JavaFontP);
   for n=8:2:16
      s.Size.add(sprintf('%d pt',n));
   end
   s.Weight = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strBold')); s.East.add(s.Weight);
      s.Weight.setFont(Prefs.JavaFontB);
   s.Angle = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strItalic')); s.East.add(s.Angle);
      s.Angle.setFont(Prefs.JavaFontI);

%---Install listeners and callbacks
 %---FontSize listener
  Property = [PropName 'FontSize'];
  s.SizeListener = handle.listener(h,findprop(h,Property),'PropertyPostSet',{@localReadProp,s.Size});
 %---FontSize callback
    s.Size.setName('FontSize');
    hc = handle(s.Size, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h,Property));
 %---FontWeight listener
  Property = [PropName 'FontWeight'];
  s.WeightListener = handle.listener(h,findprop(h,Property),'PropertyPostSet',{@localReadProp,s.Weight});
 %---FontWeight callback
    s.Weight.setName('FontWeight');
    hc = handle(s.Weight, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h,Property));
 %---FontAngle listener
  Property = [PropName 'FontAngle'];
  s.AngleListener = handle.listener(h,findprop(h,Property),'PropertyPostSet',{@localReadProp,s.Angle});
 %---FontAngle callback
    s.Angle.setName('FontAngle');
    hc = handle(s.Angle, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h,Property));

%---Store java handles
set(Panel,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,GUI)
% Update GUI when property changes
switch char(GUI.getName)
case 'FontSize'
   GUI.select((eventData.NewValue-8)/2);
case 'FontWeight'
   GUI.setState(strcmpi(eventData.NewValue,'bold'));
case 'FontAngle'
   GUI.setState(strcmpi(eventData.NewValue,'italic'));
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,Property)
% Update property when GUI changes
switch char(eventSrc.getName)
case 'FontSize'
   Value = 8 + 2*eventSrc.getSelectedIndex;
case 'FontWeight'
   if eventSrc.getState
      Value = 'bold';
   else
      Value = 'normal';
   end
case 'FontAngle'
   if eventSrc.getState
      Value = 'italic';
   else
      Value = 'normal';
   end
end
set(h,Property,Value);

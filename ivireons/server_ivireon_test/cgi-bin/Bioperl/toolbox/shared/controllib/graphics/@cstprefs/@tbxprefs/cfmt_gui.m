function Main = cfmt_gui(h)
%CFMT_GUI  GUI for editing Siso Tool Compensator Format of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:45:03 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
GL_31 = java.awt.GridLayout(3,1,0,5);
FL_L = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,15,0);
LL = com.mathworks.mwt.MWLabel.LEFT;
LC = com.mathworks.mwt.MWLabel.CENTER;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Controllib:gui:strCompensatorFormat'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Main panel
s.M = com.mathworks.mwt.MWPanel(GL_31); Main.add(s.M,com.mathworks.mwt.MWBorderLayout.CENTER);

%---Exclusive group
GRP = com.mathworks.mwt.MWExclusiveGroup;

%---Time-constant
str = sprintf('%s       DC x (1 + Tz s) / (1 + Tp s)', ...
    ctrlMsgUtils.message('Controllib:gui:strTimeConstantLabel'));
s.TCW1 = com.mathworks.mwt.MWCheckbox(sprintf('%s',str),GRP,1); s.M.add(s.TCW1);
s.TCW1.setFont(Prefs.JavaFontP);

%---Time-constant 2
str = sprintf('%s   DC x (1 + s/wz) / (1 + s/wp)', ...
    ctrlMsgUtils.message('Controllib:gui:strNaturalFrequencyLabel'));
s.TCW2 = com.mathworks.mwt.MWCheckbox(sprintf('%s',str),GRP,0);
s.M.add(s.TCW2);
s.TCW2.setFont(Prefs.JavaFontP);

%---Zero/pole/gain
str = sprintf('%s       K x (s + z) / (s + p)',...
    ctrlMsgUtils.message('Controllib:gui:strZPKLabel'));
s.ZPW1 = com.mathworks.mwt.MWCheckbox(sprintf('%s',str),GRP,0); s.M.add(s.ZPW1);
s.ZPW1.setFont(Prefs.JavaFontP);

%---Install listeners and callbacks
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h};
%---Compensator Format
s.CompensatorFormatListener = handle.listener(h,findprop(h,'CompensatorFormat'),'PropertyPostSet',Callback);
s.TCW1.setName('TimeConstant1');
hc = handle(s.TCW1, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));
s.TCW2.setName('TimeConstant2');
hc = handle(s.TCW2, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));
s.ZPW1.setName('ZeroPoleGain');
hc = handle(s.ZPW1, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h));

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Update GUI when property changes
switch eventData.NewValue
 case 'TimeConstant1'
  s.TCW1.setState(1);
 case 'TimeConstant2'
  s.TCW2.setState(1);
 case 'ZeroPoleGain'
  s.ZPW1.setState(1);
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% Update property when GUI changes
h.CompensatorFormat = char(eventSrc.getName);

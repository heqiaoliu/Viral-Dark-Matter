function Main = ls_gui(h)
%LS_GUI  GUI for editing line color/style properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.11.4.5 $  $Date: 2010/04/21 21:10:42 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
WEST   = com.mathworks.mwt.MWBorderLayout.WEST;
CENTER = com.mathworks.mwt.MWBorderLayout.CENTER;
EAST   = com.mathworks.mwt.MWBorderLayout.EAST;
GL     = java.awt.GridLayout(6,1,0,3);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Line Colors'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(10,0));
Main.setFont(Prefs.JavaFontB);

s.W = com.mathworks.mwt.MWPanel(GL); Main.add(s.W,WEST);
s.C = com.mathworks.mwt.MWPanel(GL); Main.add(s.C,CENTER);
s.E = com.mathworks.mwt.MWPanel(GL); Main.add(s.E,EAST);

s.L1 = com.mathworks.mwt.MWLabel(sprintf('Plant Components:')); s.W.add(s.L1);
s.L1.setFont(Prefs.JavaFontP);
s.L2 = com.mathworks.mwt.MWLabel(sprintf('Feedback Compensators:')); s.W.add(s.L2);
s.L2.setFont(Prefs.JavaFontP);
s.L3 = com.mathworks.mwt.MWLabel(sprintf('Feedforward Compensators:')); s.W.add(s.L3);
s.L3.setFont(Prefs.JavaFontP);
s.L4 = com.mathworks.mwt.MWLabel(sprintf('Open Loop:')); s.W.add(s.L4);
s.L4.setFont(Prefs.JavaFontP);
s.L5 = com.mathworks.mwt.MWLabel(sprintf('Closed Loop:')); s.W.add(s.L5);
s.L5.setFont(Prefs.JavaFontP);
s.L6 = com.mathworks.mwt.MWLabel(sprintf('Margins:')); s.W.add(s.L6);
s.L6.setFont(Prefs.JavaFontP);

s.E1 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E1);
s.E1.setFont(Prefs.JavaFontP);
s.E2 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E2);
s.E2.setFont(Prefs.JavaFontP);
s.E3 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E3);
s.E3.setFont(Prefs.JavaFontP);
s.E4 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E4);
s.E4.setFont(Prefs.JavaFontP);
s.E5 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E5);
s.E5.setFont(Prefs.JavaFontP);
s.E6 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E6);
s.E6.setFont(Prefs.JavaFontP);

s.B1 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B1);
s.B1.setFont(Prefs.JavaFontP);
s.B2 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B2);
s.B2.setFont(Prefs.JavaFontP);
s.B3 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B3);
s.B3.setFont(Prefs.JavaFontP);
s.B4 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B4);
s.B4.setFont(Prefs.JavaFontP);
s.B5 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B5);
s.B5.setFont(Prefs.JavaFontP);
s.B6 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B6);
s.B6.setFont(Prefs.JavaFontP);

%---Install listeners and callbacks
LCallback = {@localReadProp,s};           % listener callback
ECallback = @(es,ed) localWriteProp(es,ed,h,'edit');   % edit callback
   %---LineStyle
    s.LineStyleListener = handle.listener(h,findprop(h,'LineStyle'),'PropertyPostSet',LCallback);
    s.E1.setName('System');
    hc = handle(s.E1, 'callbackproperties');
    set(hc,'ActionPerformedCallback',ECallback);
    set(hc,'FocusLostCallback',ECallback);
    set(hc,'ComponentResizedCallback',@(es,ed) localResetCaret(es,ed));
    s.E2.setName('Compensator');
    hc = handle(s.E2, 'callbackproperties');
    set(hc,'ActionPerformedCallback',ECallback);
    set(hc,'FocusLostCallback',ECallback);
    set(hc,'ComponentResizedCallback',@(es,ed) localResetCaret(es,ed));  
    s.E3.setName('PreFilter');
    hc = handle(s.E3, 'callbackproperties');
    set(hc,'ActionPerformedCallback',ECallback);
    set(hc,'FocusLostCallback',ECallback);
    set(hc,'ComponentResizedCallback',@(es,ed) localResetCaret(es,ed));
    s.E4.setName('Response');
    hc = handle(s.E4, 'callbackproperties');
    set(hc,'ActionPerformedCallback',ECallback);
    set(hc,'FocusLostCallback',ECallback);
    set(hc,'ComponentResizedCallback',@(es,ed) localResetCaret(es,ed));
    s.E5.setName('ClosedLoop');
    hc = handle(s.E5, 'callbackproperties');
    set(hc,'ActionPerformedCallback',ECallback);
    set(hc,'FocusLostCallback',ECallback);
    set(hc,'ComponentResizedCallback',@(es,ed) localResetCaret(es,ed));
    s.E6.setName('Margin');
    hc = handle(s.E6, 'callbackproperties');
    set(hc,'ActionPerformedCallback',ECallback);
    set(hc,'FocusLostCallback',ECallback);
    set(hc,'ComponentResizedCallback',@(es,ed) localResetCaret(es,ed));
    
    s.B1.setName('System');
    hc = handle(s.B1, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,'Plant & Sensor'));  
    s.B2.setName('Compensator');
    hc = handle(s.B2, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,'Compensator'));
    s.B3.setName('PreFilter');
    hc = handle(s.B3, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,'Prefilter'));
    s.B4.setName('Response');
    hc = handle(s.B4, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,'Plot Lines'));
    s.B5.setName('ClosedLoop');
    hc = handle(s.B5, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,'Closed Loop'));
    s.B5.setName('Margin');
    hc = handle(s.B5, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,'Margins'));

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%%%
% localResetCaret %
%%%%%%%%%%%%%%%%%%%
function localResetCaret(eventSrc,eventData)
% Hack to ensure that text in MWTextField is visible
eventSrc.setCaretPosition(1);
eventSrc.setCaretPosition(0);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Update GUI when property changes
Color = eventData.NewValue.Color;
s.E1.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.System));      % Plant & Sensor
s.E2.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.Compensator)); % Feedback compensators
s.E3.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.PreFilter));   % Feedforward compensators
s.E4.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.Response));    % Plot Lines
s.E5.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.ClosedLoop));  % Closed Loop
s.E6.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.Margin));      % Margins


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,action)
% Update property when GUI changes
Name = char(eventSrc.getName);
LineStyle = h.LineStyle;
oldval = LineStyle.Color.(Name);
switch action
case 'edit'
   newval = evalnum(char(eventSrc.getText));
   if isempty(newval)
      %---Invalid number: revert to original value
      eventSrc.setText(sprintf('[%0.3g %0.3g %0.3g]',oldval));
   elseif ~isequal(oldval,newval)
      newval = max(min(newval,1),0);
      eventSrc.setText(sprintf('[%0.3g %0.3g %0.3g]',newval));
      LineStyle.Color.(Name) = newval;
      h.LineStyle = LineStyle;
   end
otherwise
   newval = uisetcolor(oldval,sprintf('Select Color: %s',action));
   if ~isequal(oldval,newval)
      LineStyle.Color.(Name) = newval;
      h.LineStyle = LineStyle;
   end
end


%%%%%%%%%%%
% evalnum %
%%%%%%%%%%%
function val = evalnum(val)
% Evaluate string val, returning valid real color vector only, empty otherwise
if ~isempty(val)
   val = evalin('base',val,'[]');
   if ~isnumeric(val) | ~(isreal(val) & isfinite(val) & isequal(size(val),[1 3]))
      val = [];
   end
end

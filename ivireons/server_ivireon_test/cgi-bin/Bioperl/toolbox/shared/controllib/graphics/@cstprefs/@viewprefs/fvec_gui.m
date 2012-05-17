function Main = fvec_gui(h)
%FVEC_GUI  GUI for editing time vector properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:45:18 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
GL_12 = java.awt.GridLayout(1,2,0,0);
GRP = com.mathworks.mwt.MWExclusiveGroup;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Controllib:gui:strFrequencyVectorLabel',Prefs.FrequencyUnits));
Main.setLayout(java.awt.GridLayout(3,1,0,4));
Main.setFont(Prefs.JavaFontB);

%---Row 1 ('Generate automatically')
s.R1 = com.mathworks.mwt.MWPanel(java.awt.GridLayout(1,1,0,0)); Main.add(s.R1);
s.Auto = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strGenerateAutomatically'),GRP,1); 
s.R1.add(s.Auto);
s.Auto.setFont(Prefs.JavaFontP);

%---Row 2 ('Define range')
s.R2 = com.mathworks.mwt.MWPanel(GL_12); Main.add(s.R2);
s.Manual1 = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strDefinerange'),GRP,0); 
s.R2.add(s.Manual1);
s.Manual1.setFont(Prefs.JavaFontP);
s.R2E = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(10,0)); s.R2.add(s.R2E);
%---Start
s.Start = com.mathworks.mwt.MWTextField(sprintf('1'),5);
set(s.Start,'Tag','1','UserData',1);  %---Tag/UserData contains last valid string/number
s.Start.setFont(Prefs.JavaFontP);
s.Start.setEnabled(0);
s.R2E.add(s.Start,com.mathworks.mwt.MWBorderLayout.WEST);
%---To
s.To = com.mathworks.mwt.MWLabel(ctrlMsgUtils.message('Controllib:gui:strTo'),com.mathworks.mwt.MWLabel.CENTER);
s.To.setFont(Prefs.JavaFontP);
s.To.setEnabled(0);
s.R2E.add(s.To,com.mathworks.mwt.MWBorderLayout.CENTER);
%---Stop
s.Stop = com.mathworks.mwt.MWTextField(sprintf('1000'),5);
set(s.Stop,'Tag','1000','UserData',1000);  %---Tag/UserData contains last valid string/number
s.Stop.setEnabled(0);
s.Stop.setFont(Prefs.JavaFontP);
s.R2E.add(s.Stop,com.mathworks.mwt.MWBorderLayout.EAST);

%---Row 3 ('Define vector')
s.R3 = com.mathworks.mwt.MWPanel(GL_12); Main.add(s.R3);
s.Manual2 = com.mathworks.mwt.MWCheckbox(ctrlMsgUtils.message('Controllib:gui:strDefineVector'),GRP,0); 
s.R3.add(s.Manual2);
s.Manual2.setFont(Prefs.JavaFontP);
%---Vector
s.Vector = com.mathworks.mwt.MWTextField(sprintf('logspace(0,3,50)'),8); s.R3.add(s.Vector);
set(s.Vector,'Tag','logspace(0,3,50)','UserData',logspace(0,3,50)); %---Tag/UserData contains last valid string/number
s.Vector.setFont(Prefs.JavaFontP);
s.Vector.setEnabled(0);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'viewprefs');
EventSrc = CLS.findprop('FrequencyVector');
s.TimeVectorListener = handle.listener(h,EventSrc,'PropertyPostSet',{@localReadProp,s});
GUICallback = {@localWriteProp,h,s};
%---Mode
s.Auto.setName('Auto');
hc = handle(s.Auto, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h,s));
s.Manual1.setName('Manual1');
hc = handle(s.Manual1, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h,s));
s.Manual2.setName('Manual2');
hc = handle(s.Manual2, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localWriteProp(es,ed,h,s));

%---Value
s.Start.setName('Start');
hc = handle(s.Start, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,s));
set(hc,'FocusLostCallback',@(es,ed) localWriteProp(es,ed,h,s));
s.Stop.setName('Stop');
hc = handle(s.Stop, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,s));
set(hc,'FocusLostCallback',@(es,ed) localWriteProp(es,ed,h,s));
s.Vector.setName('Vector');
hc = handle(s.Vector, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localWriteProp(es,ed,h,s));
set(hc,'FocusLostCallback',@(es,ed) localWriteProp(es,ed,h,s));

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Target -> GUI
h = eventData.AffectedObject;
NewValue = eventData.NewValue;  % value of FrequencyVector
if isempty(NewValue)
   % Reverting to auto mode
   s.Auto.setState(1);
   s.Start.setEnabled(0); s.Start.repaint;
   s.To.setEnabled(0); s.To.repaint;
   s.Stop.setEnabled(0); s.Stop.repaint;
   s.Vector.setEnabled(0); s.Vector.repaint;
elseif isa(NewValue,'cell')
   % Specifying the frequency range
   s.Manual1.setState(1);
   s.Start.setEnabled(1); s.Start.repaint;
   s.To.setEnabled(1); s.To.repaint;
   s.Stop.setEnabled(1); s.Stop.repaint;
   s.Vector.setEnabled(0); s.Vector.repaint;
   % Update values
   if ~isequal(NewValue,{get(s.Start,'UserData') get(s.Stop,'UserData')})
      str1 = makestr(NewValue{1});
      str2 = makestr(NewValue{2});
      s.Start.setText(str1);
      set(s.Start,'Tag',str1,'UserData',NewValue{1});
      s.Stop.setText(str2);
      set(s.Stop,'Tag',str2,'UserData',NewValue{2});
   end
else
   % Specifying a frequency vector
   s.Manual2.setState(1);
   s.Start.setEnabled(0); s.Start.repaint;
   s.To.setEnabled(0); s.To.repaint;
   s.Stop.setEnabled(0); s.Stop.repaint;
   s.Vector.setEnabled(1); s.Vector.repaint;
   % Update value display
   if ~isempty(NewValue) & ~isequal(NewValue,get(s.Vector,'UserData'))
      str = makestr(NewValue);
      s.Vector.setText(str);
      set(s.Vector,'Tag',str,'UserData',NewValue);
   end
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,s)
% GUI -> Target
switch char(eventSrc.getName)
case 'Auto'
   h.FrequencyVector = [];
case 'Manual1'
   h.FrequencyVector = {get(s.Start,'UserData') get(s.Stop,'UserData')};
case 'Manual2'
   h.FrequencyVector = get(s.Vector,'UserData');
case 'Start'
   if eventSrc.isEnabled
      oldval = get(s.Start,'UserData');
      oldvec = [oldval get(s.Stop,'UserData')];
      oldstr = get(s.Start,'Tag');
      newstr = char(s.Start.getText);
      newval = evalnum(newstr,1);
      if isempty(newval) | newval>=oldvec(2)
         s.Start.setText(oldstr);
      elseif ~isequal(oldval,newval)
         set(s.Start,'Tag',newstr,'UserData',newval);
         h.FrequencyVector = {newval oldvec(2)};
      end
   end
case 'Stop'
   if eventSrc.isEnabled
      oldval = get(s.Stop,'UserData');
      oldvec = [get(s.Start,'UserData') oldval];
      oldstr = get(s.Stop,'Tag');
      newstr = char(s.Stop.getText);
      newval = evalnum(newstr,1);
      if isempty(newval) | newval<=oldvec(1)
         s.Stop.setText(oldstr);
      elseif ~isequal(oldval,newval)
         set(s.Stop,'Tag',newstr,'UserData',newval);
         h.FrequencyVector = {oldvec(1) newval};
      end
   end
case 'Vector'
   if eventSrc.isEnabled
      oldval = get(s.Vector,'UserData');
      oldstr = get(s.Vector,'Tag');
      newstr = char(s.Vector.getText);
      newval = evalnum(newstr,inf);
      if isempty(newval)
         s.Vector.setText(oldstr);
      elseif ~isequal(oldval,newval)
         set(s.Vector,'Tag',newstr,'UserData',newval);
         h.FrequencyVector = newval;
      end
   end
end


%%%%%%%%%%%
% evalnum %
%%%%%%%%%%%
function val = evalnum(val,n)
% Evaluate string val
if ~isempty(val)
   val = evalin('base',val,'[]');
   if ~isnumeric(val) | ~(isreal(val) & isfinite(val))
      val = [];
   else
      val = val(:);
      %---Case: val must be same length as n
      if n<inf & length(val)==n
         %---Make sure val is >0
         if val<=0
            val = [];
         end
         %---Case: val is vector (length>2)
      elseif n==inf & length(val)>2
         %---Make sure all of val is >0
         if ~all(val>0)
            val = [];
         end
      else
         val = [];
      end
   end
end


%%%%%%%%%%%
% makestr %
%%%%%%%%%%%
function str = makestr(val)
% Build a nice display string for val
lval = length(val);
if lval==0
   str = '';
elseif lval==1
   str = num2str(val);
elseif lval==2
   str = sprintf('[%0.3g %0.3g]',val(1),val(end));
else
   dval   = diff(val);
   val10  = log10(val);
   dval10 = diff(val10);
   tol    = 100*eps*max(val);
   tol10  = 100*eps*max(val10);
   if all(abs(dval-dval(1))<tol)
      %---Build compact vector (even step size)
      str = sprintf('[%s:%s:%s]',num2str(val(1)),num2str(dval(1)),num2str(val(end)));
   elseif all(abs(dval10-dval10(1))<tol10)
      %---Build logspace string
      str = sprintf('logspace(%s,%s,%d)',num2str(val10(1)),num2str(val10(end)),lval);
   elseif lval<=20
      %---Generic case (show all values, as long as the vector isn't too long!)
      str = sprintf('%g ',val);
      str = sprintf('[%s]',str(1:end-1));
   else
      %---Default string
      str = 'logspace(0,3,50)';
   end
end

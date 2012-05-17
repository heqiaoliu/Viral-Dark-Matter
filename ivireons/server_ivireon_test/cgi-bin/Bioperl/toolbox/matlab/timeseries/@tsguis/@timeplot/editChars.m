function TextBox = editChars(this,BoxLabel,BoxPool)
%EDITCHARS  Builds group box for editing Characteristics.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2007/10/15 22:55:48 $

% Look for a group box with matching Tag in the pool of group boxes

TextBox = find(handle(BoxPool),'Tag',BoxLabel);

if isempty(TextBox)
   % Create group box if not found
   TextBox = LocalCreateUI(this);
end
TextBox.GroupBox.setLabel(sprintf('Characteristics'));

%%%%%%%%%%%%% Targeting CallBacks.... (Write the Plot Properties into the GUI) %%%%%%%%%%%
TextBox.Target = this;
TextBox.TargetListeners = ...
    [handle.listener(this,findprop(this,'Options'),'PropertyPostSet',{@localReadProp TextBox,this});...
     handle.listener(this.PropEditor,'PropEditBeingClosed',{@localWriteProp,TextBox})];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = get(TextBox.GroupBox,'UserData');

%------------------ Local Functions ------------------------
function OptionsBox = LocalCreateUI(h)

% Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Create @editbox instance
OptionsBox = cstprefs.editbox;

%---Definitions
WEST   = com.mathworks.mwt.MWBorderLayout.WEST;
CENTER = com.mathworks.mwt.MWBorderLayout.CENTER;
FL_L50 = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,5,0);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Time Series Characteristics'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Response Characteristics panel
s.RC = com.mathworks.mwt.MWPanel(java.awt.GridLayout(2,1,0,4));
Main.add(s.RC,com.mathworks.mwt.MWBorderLayout.WEST);

%--- GUI CallBacks.... (Write the GUI Values into the Plot Properties)
%GUICallback = {@localWriteProp,OptionsBox};
%---SettlingTime
% s.R2 = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0)); s.RC.add(s.R2);
% s.SettlingTime = com.mathworks.mwt.MWLabel(sprintf('Show settling time within')); 
% s.R2.add(s.SettlingTime,WEST);
% s.SettlingTime.setFont(Prefs.JavaFontP);
% %---SettlingTimeThreshold
% s.R2E = com.mathworks.mwt.MWPanel(FL_L50); 
% s.R2.add(s.R2E,CENTER);
% s.SettlingTimeThreshold = com.mathworks.mwt.MWTextField(3); s.R2E.add(s.SettlingTimeThreshold);
% s.SettlingTimeThreshold.setFont(Prefs.JavaFontP);
% s.R2EL1 = com.mathworks.mwt.MWLabel(sprintf('%%')); s.R2E.add(s.R2EL1);
% s.R2EL1.setFont(Prefs.JavaFontP);
% %---SettlingTimeThreshold
% set(s.SettlingTimeThreshold,'Name','SettlingTimeThreshold',...
%     'ActionPerformedCallback',GUICallback);

%---Store java handles
set(Main,'UserData',s);
OptionsBox.GroupBox = Main;
OptionsBox.Tag = sprintf('%s',h.tag,'Characteristics');

%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,TextBox,h)
% Update GUI when property changes
s = get(TextBox.GroupBox,'UserData');
NewValue = eventData.NewValue;
%---Set GUI state/text
awtinvoke(s.SettlingTimeThreshold,'setText(Ljava.lang.String;)',...
    num2str(NewValue.SettlingTimeThreshold*100));
if strcmpi(h.Tag,'step')
   awtinvoke(s.RiseTimeLimits1,'setText(Ljava.lang.String;)',...
       num2str(NewValue.RiseTimeLimits(1)*100)); 
   awtinvoke(s.RiseTimeLimits2,'setText(Ljava.lang.String;)',...
       num2str(NewValue.RiseTimeLimits(2)*100));
end

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
% function localWriteProp(eventSrc,eventData,TextBox)
% % Update property when GUI changes
% 
% h = TextBox.Target;
% s = get(TextBox.GroupBox,'UserData');
% Prefs = h.Preferences;
% isChanged = false; 
% 
% % Settling Time
% STOldVal = h.Preferences.SettlingTimeThreshold;
% STCurrentVal = evalnum(char(s.SettlingTimeThreshold.getText))/100;
% 
% if ~isequal(STOldVal,STCurrentVal) && ~isempty(STCurrentVal)
%     isChanged = true;
%     STCurrentVal = max(min(STCurrentVal,1),0);
%     Prefs.SettlingTimeThreshold = STCurrentVal;
%     s.SettlingTimeThreshold.setText(num2str(STCurrentVal*100));
% else
%     % revert back to old value
%     s.SettlingTimeThreshold.setText(num2str(STOldVal*100));
% end
% 
% if isChanged
%     h.Preferences = Prefs;
% end

%%%%%%%%%%%
% evalnum %
%%%%%%%%%%%
function val = evalnum(val)
% Evaluate string val, returning valid real scalar only, empty otherwise
if ~isempty(val)
   val = evalin('base',val,'[]');
   if ~isnumeric(val) | ~(isreal(val) & isfinite(val) & isequal(size(val),[1 1]))
      val = [];
   end
end

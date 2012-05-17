function TextBox = editChars(this,BoxLabel,BoxPool)
%EDITCHARS  Builds group box for editing Characteristics.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/04/30 00:39:53 $

% Look for a group box with matching Tag in the pool of group boxes

TextBox = find(handle(BoxPool),'Tag',BoxLabel);
if isempty(TextBox)
   % Create group box if not found
   TextBox = LocalCreateUI(this);
end
    
%%%%%%%%%%%%% Targeting CallBacks.... (Write the Plot Properties into the GUI) %%%%%%%%%%%
TextBox.Target = this;
TextBox.TargetListeners = ...
   [handle.listener(this,findprop(this,'Options'),'PropertyPostSet',{@localReadProp TextBox,this});...
    handle.listener(this,findprop(this,'FrequencyUnits'),'PropertyPreSet',{@LocalFreqUnitsChanged TextBox,this}); ...
    handle.listener(this.AxesGrid,findprop(this.AxesGrid,'XUnits'),'PropertyPreSet',{@LocalMagPhaseUnitsChanged TextBox,this})];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = get(TextBox.GroupBox,'UserData');

% Initialization.....................
s.UnwrapPhase.setState(strcmpi(this.Options.UnwrapPhase,'on'));
s.ComparePhaseBox.setState(strcmpi(this.Options.ComparePhase.Enable,'on'));
s.CompareFreq.setText(sprintf('%.3f',this.Options.ComparePhase.Freq));
s.ComparePhase.setText(sprintf('%.3f',this.Options.ComparePhase.Phase));
LocalEnableComparePhase(s, strcmpi(this.Options.ComparePhase.Enable,'on'));
s.MinGainBox.setState(strcmpi(this.Options.MinGainLimit.Enable,'on'));
s.MinGainEdit.setText(sprintf('%.3f',this.Options.MinGainLimit.MinGain));
LocalEnableMinGain(s,strcmpi(this.Options.MinGainLimit.Enable,'on'));


%------------------ Local Functions ------------------------
function TextBox = LocalCreateUI(h)

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Create @editbox instance
TextBox = cstprefs.editbox;


%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWPanel;
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%% Phase Options
s.PCGB = com.mathworks.mwt.MWGroupbox(sprintf('Phase Response'));
s.PCGB.setFont(Prefs.JavaFontB);
s.PCGB.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.add(s.PCGB,com.mathworks.mwt.MWBorderLayout.SOUTH);
s.PC = com.mathworks.mwt.MWPanel;
s.PC.setLayout(com.mathworks.page.utils.VertFlowLayout(java.awt.FlowLayout.LEFT));
s.PCGB.add(s.PC,com.mathworks.mwt.MWBorderLayout.CENTER)

%% Magnitude Options 
s.MCGB = com.mathworks.mwt.MWGroupbox(sprintf('Magnitude Response'));
s.MCGB.setFont(Prefs.JavaFontB);
s.MCGB.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.add(s.MCGB,com.mathworks.mwt.MWBorderLayout.NORTH);
s.MC = com.mathworks.mwt.MWPanel;
s.MC.setLayout(com.mathworks.page.utils.VertFlowLayout(java.awt.FlowLayout.LEFT));
s.MCGB.add(s.MC,com.mathworks.mwt.MWBorderLayout.CENTER);


%% Phase Options subpanels
%---Checkbox Unwrap Phase
s.UnwrapPhase = com.mathworks.mwt.MWCheckbox(sprintf('Unwrap phase'));
s.UnwrapPhase.setFont(Prefs.JavaFontP);
s.PC.add(s.UnwrapPhase);

%---Checkbox Compare Phase
s.ComparePhaseBox = com.mathworks.mwt.MWCheckbox(sprintf('Adjust phase offsets'));
s.ComparePhaseBox.setFont(Prefs.JavaFontP);
s.PC.add(s.ComparePhaseBox);

s.PMFP = com.mathworks.mwt.MWPanel(java.awt.GridLayout(2,3,10,4));

s.PMFreq = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,1));
s.FreqLabel = com.mathworks.mwt.MWLabel(sprintf('At frequency:'));
s.CompareFreq = com.mathworks.mwt.MWTextField(sprintf('%.3f',0),14);
s.PMFreq.add(com.mathworks.mwt.MWLabel(sprintf('            ')));
s.PMFreq.add(s.FreqLabel);
s.PMFSpace = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,1));
s.PMFSpace.add(s.CompareFreq);

s.PMPhase = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,1));
s.PhaseLabel = com.mathworks.mwt.MWLabel(sprintf('Keep phase close to:'));
s.ComparePhase = com.mathworks.mwt.MWTextField(sprintf('%.3f',0),14);
s.PMPhase.add(com.mathworks.mwt.MWLabel(sprintf('            ')));
s.PMPhase.add(s.PhaseLabel);
s.PMPSpace = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,1));
s.PMPSpace.add(s.ComparePhase);


% Add panels
s.PMFP.add(s.PMPhase);
s.PMFP.add(s.PMPSpace);
s.PMFP.add(s.PMFreq);
s.PMFP.add(s.PMFSpace);

s.PC.add(s.PMFP);
s.PC.setFont(Prefs.JavaFontP);

%% Magnitude Options subpanels
% Bandwidth
% s.BWPanel = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,1));
% s.BandwidthText = com.mathworks.mwt.MWLabel(sprintf('Bandwidth Threshold: '));
% s.BWPanel.add(s.BandwidthText);
% s.BandwidthThreshold = com.mathworks.mwt.MWTextField(sprintf('%.3f',0),5);
% s.BWPanel.add(s.BandwidthThreshold);
% s.BandwidthUnits = com.mathworks.mwt.MWLabel(sprintf(' dB'));
% s.BWPanel.add(s.BandwidthUnits);
% s.MC.add(s.BWPanel);


% Min Gain
s.MGPanel = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT,0,1));
s.MinGainBox = com.mathworks.mwt.MWCheckbox(sprintf('Only show magnitude above:  '));
s.MinGainBox.setFont(Prefs.JavaFontP);
s.MGPanel.add(s.MinGainBox);
s.MinGainEdit = com.mathworks.mwt.MWTextField(sprintf('%.3f',0),14);
s.MGPanel.add(s.MinGainEdit);
s.MC.add(s.MGPanel);



%% --- GUI CallBacks.... (Write the GUI Values into the Plot Properties)
GUICallback = {@localWriteUnwrapProp,TextBox};
s.UnwrapPhase.setName('UnwrapPhase');
hc = handle(s.UnwrapPhase, 'callbackproperties');
set(hc,'ItemStateChangedCallback',GUICallback);

s.ComparePhaseBox.setName('ComparePhaseBox');
hc = handle(s.ComparePhaseBox, 'callbackproperties');
set(hc,'ItemStateChangedCallback',{@LocalWriteComparePhase TextBox});

s.CompareFreq.setName('CompareFreq');
hc = handle(s.CompareFreq, 'callbackproperties');
set(hc,'ActionPerformedCallback',{@LocalWriteCompareFreqEdit TextBox});
set(hc,'FocusLostCallback',{@LocalWriteCompareFreqEdit TextBox});

s.ComparePhase.setName('ComparePhase');
hc = handle(s.ComparePhase, 'callbackproperties');
set(hc,'ActionPerformedCallback',{@LocalWriteComparePhaseEdit TextBox});
set(hc,'FocusLostCallback',{@LocalWriteComparePhaseEdit TextBox});

s.MinGainBox.setName('MinGainBox');
hc = handle(s.MinGainBox, 'callbackproperties');
set(hc,'ItemStateChangedCallback',{@LocalWriteMinGainBox TextBox});

s.MinGainEdit.setName('MinGainEdit');
hc = handle(s.MinGainEdit, 'callbackproperties');
set(hc,'ActionPerformedCallback',{@LocalWriteMinGainEdit TextBox});
set(hc,'FocusLostCallback',{@LocalWriteMinGainEdit TextBox});


%---Store java handles
set(Main,'UserData',s);
TextBox.GroupBox = Main;
TextBox.Tag = 'Characteristics';


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,TextBox,h)
% Update GUI when property changes
GUI = get(TextBox.GroupBox,'UserData');
Prefs = eventData.NewValue;
GUI.UnwrapPhase.setState(strcmpi(Prefs.UnwrapPhase,'on'));
GUI.ComparePhaseBox.setState(strcmpi(Prefs.ComparePhase.Enable,'on'));
GUI.CompareFreq.setText(sprintf('%.3f',Prefs.ComparePhase.Freq));
GUI.ComparePhase.setText(sprintf('%.3f',Prefs.ComparePhase.Phase));
GUI.MinGainBox.setState(strcmpi(Prefs.MinGainLimit.Enable,'on'));
GUI.MinGainEdit.setText(sprintf('%.3f',Prefs.MinGainLimit.MinGain));
LocalEnableComparePhase(GUI, strcmpi(Prefs.ComparePhase.Enable,'on'));
LocalEnableMinGain(GUI,strcmpi(Prefs.MinGainLimit.Enable,'on'));

%%%%%%%%%%%%%%%%%%
% localWriteUnwrapProp %
%%%%%%%%%%%%%%%%%%
function localWriteUnwrapProp(eventSrc,eventData,TextBox)
% Update property when GUI changes
if eventSrc.getState
    UnwrapPhase = 'on';
else
    UnwrapPhase = 'off';
end

TextBox.Target.Options.UnwrapPhase = UnwrapPhase;

    

%%%%%%%%%%%%%%%%%%
% localWriteComparePhase %
%%%%%%%%%%%%%%%%%%
function LocalWriteComparePhase(eventSrc,eventData,TextBox)
% Update property when GUI changes

s = get(TextBox.GroupBox,'UserData');

if s.ComparePhaseBox.getState
    NewState = 'on';
else
    NewState = 'off';
end

TextBox.Target.Options.ComparePhase.Enable = NewState ;

% Enable Disable Fields
LocalEnableComparePhase(s, strcmpi(NewState,'on'));

%%%%%%%%%%%%%%%%%%
% localWriteComparePhaseEdit %
%%%%%%%%%%%%%%%%%%
function LocalWriteComparePhaseEdit(eventSrc,eventData,TextBox)
% Update property when GUI changes
if ishandle(TextBox.Target)
    NewValue = str2num(char(eventSrc.getText));
    if ~isempty(NewValue) && isnumeric(NewValue) && isscalar(NewValue) && isfinite(NewValue)
        TextBox.Target.Options.ComparePhase.Phase = double(full(NewValue));
    else
        eventSrc.setText(sprintf('%.3f',TextBox.Target.Options.ComparePhase.Phase));
    end
end

%%%%%%%%%%%%%%%%%%
% localWriteCompareFreqEdit %
%%%%%%%%%%%%%%%%%%
function LocalWriteCompareFreqEdit(eventSrc,eventData,TextBox)
% Update property when GUI changes
if ishandle(TextBox.Target)
    NewValue = str2num(char(eventSrc.getText));
    if ~isempty(NewValue) && isnumeric(NewValue) && isscalar(NewValue) && isfinite(NewValue)
        TextBox.Target.Options.ComparePhase.Freq = double(full(NewValue));
    else
        eventSrc.setText(sprintf('%.3f',TextBox.Target.Options.ComparePhase.Freq));
    end
end



%%%%%%%%%%%%%%%%%%%%%
% localWriteMinGainBox %
%%%%%%%%%%%%%%%%%%%%%
function LocalWriteMinGainBox(eventSrc,eventData,TextBox)
% Update property when GUI changes

s = get(TextBox.GroupBox,'UserData');
if s.MinGainBox.getState
    NewState = 'on';
else
    NewState = 'off';
end

TextBox.Target.Options.MinGainLimit.Enable = NewState ;

% Enable Disable Fields
LocalEnableMinGain(s, strcmpi(NewState,'on'));

%%%%%%%%%%%%%%%%%%%%%
% localWriteMinGainEdit %
%%%%%%%%%%%%%%%%%%%%%
function LocalWriteMinGainEdit(eventSrc,eventData,TextBox)
% Update property when GUI changes
if ishandle(TextBox.Target)
    NewValue = str2num(char(eventSrc.getText));
    if ~isempty(NewValue) && isnumeric(NewValue) && isscalar(NewValue) && isfinite(NewValue)
        TextBox.Target.Options.MinGainLimit.MinGain = double(full(NewValue));
    else
       eventSrc.setText(sprintf('%.3f',TextBox.Target.Options.MinGainLimit.MinGain));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalFreqUnitsChanged %
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalFreqUnitsChanged(eventSrc,eventData,TextBox, this)
% Update GUI when property changes
GUI = get(TextBox.GroupBox,'UserData');

% Get old and new units
OldUnits = eventData.AffectedObject.FrequencyUnits;
NewUnits = eventData.NewValue;

% Update freq for comparison
NewFreq = unitconv(this.Options.ComparePhase.Freq,OldUnits,NewUnits);
GUI.CompareFreq.setText(sprintf('%.3f',NewFreq))

% Update Options
this.Options.ComparePhase.Freq = NewFreq;



%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalMagPhaseUnitsChanged %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMagPhaseUnitsChanged(eventSrc,eventData,TextBox, this)
% Update GUI when property changes
GUI = get(TextBox.GroupBox,'UserData');

% Get old and new phase units
OldPhaseUnits = eventData.AffectedObject.XUnits;
NewPhaseUnits = eventData.NewValue;

% Update phase for comparison
NewPhase = unitconv(this.Options.ComparePhase.Phase,OldPhaseUnits,NewPhaseUnits);
GUI.ComparePhase.setText(sprintf('%.3f',NewPhase))

% Update Options
this.Options.ComparePhase.Phase = NewPhase;


function LocalEnableComparePhase(s,enstate)
% Enable Disable Fields
s.FreqLabel.setEnabled(enstate);
s.CompareFreq.setEnabled(enstate);
s.PhaseLabel.setEnabled(enstate);
s.ComparePhase.setEnabled(enstate);
s.PCGB.repaint

function LocalEnableMinGain(s,enstate)
% Enable Disable Fields
s.MinGainEdit.setEnabled(enstate);
s.MCGB.repaint;









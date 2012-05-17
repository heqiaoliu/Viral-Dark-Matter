function Main = pade_gui(this)
%PADE_GUI  GUI for editing pade options of h

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2009/07/09 20:51:23 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
CENTER = com.mathworks.mwt.MWBorderLayout.CENTER;
NORTH = com.mathworks.mwt.MWBorderLayout.NORTH;


%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Control:compDesignTask:strApproxLabel'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);
   
%---Pade Order Edit Panel
s.IntroLabel = javaObjectEDT('com.mathworks.mwswing.MJTextArea', ...
    ctrlMsgUtils.message('Control:compDesignTask:strPadeDescLabel'),2,30);
s.IntroLabel.setLineWrap(true);
s.IntroLabel.setWrapStyleWord(true);
s.IntroLabel.setBackground(Main.getBackground)
Main.add(s.IntroLabel,NORTH);

s.PadeSelectPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel', ...
    com.mathworks.page.utils.VertFlowLayout(com.mathworks.page.utils.VertFlowLayout.LEFT));
s.PadeSelectPanel.setBorder(javax.swing.border.EmptyBorder(0,15,0,0));
Main.add(s.PadeSelectPanel,CENTER);

s.PadeRadioButton = javaObjectEDT('com.mathworks.mwswing.MJRadioButton', ...
    ctrlMsgUtils.message('Control:compDesignTask:strPadeLabel'));
s.PadeRadioButton.setFont(Prefs.JavaFontP);
s.PadeRadioButton.setName('PadeRadioButton');
s.PadeOrder = javaObjectEDT('com.mathworks.mwswing.MJTextField',8); 
s.PadeOrder.setName('PadeOrderEditField');
s.PadeOrder.setFont(Prefs.JavaFontP);

s.BandwidthRadioButton = javaObjectEDT('com.mathworks.mwswing.MJRadioButton', ...
    ctrlMsgUtils.message('Control:compDesignTask:strBandWidthLabel'));
s.BandwidthRadioButton.setFont(Prefs.JavaFontP);
s.BandwidthRadioButton.setName('BandwidthRadioButton');
s.Bandwidth = javaObjectEDT('com.mathworks.mwswing.MJTextField',8); 
s.Bandwidth.setFont(Prefs.JavaFontP);
s.Bandwidth.setName('BandWidthEditField');
s.BandwidthPadeLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('(%s %d)',ctrlMsgUtils.message('Control:compDesignTask:strPadeLabel'),0));



% Create button group, 
% This allows only one radio button in the group selected at a time
RadioBtnGroup = javaObjectEDT('javax.swing.ButtonGroup');
RadioBtnGroup.add(s.PadeRadioButton);
RadioBtnGroup.add(s.BandwidthRadioButton);

SubPanel2a = javaObjectEDT('com.mathworks.mwswing.MJPanel', ...
    java.awt.FlowLayout(java.awt.FlowLayout.LEFT));
SubPanel2a.add(s.PadeRadioButton);
SubPanel2a.add(s.PadeOrder);

SubPanel2b = javaObjectEDT('com.mathworks.mwswing.MJPanel', ...
    java.awt.FlowLayout(java.awt.FlowLayout.LEFT));
SubPanel2b.add(s.BandwidthRadioButton);
SubPanel2b.add(s.Bandwidth);
SubPanel2b.add(s.BandwidthPadeLabel);

s.PadeSelectPanel.add(SubPanel2a);
s.PadeSelectPanel.add(SubPanel2b);


%---Install listeners and callbacks

h1 = handle(s.PadeRadioButton, 'callbackproperties' ); 
h1.ActionPerformedCallback = {@localPadeRadioButton this};


h2 = handle(s.BandwidthRadioButton, 'callbackproperties' ); 
h2.ActionPerformedCallback = {@localBandwidthRadioButton this};

h3 = handle(s.PadeOrder, 'callbackproperties');
h3.ActionPerformedCallback = {@localWritePadeProp, this};
h3.FocusLostCallback = {@localWritePadeProp, this};

h4 = handle(s.Bandwidth, 'callbackproperties');
h4.ActionPerformedCallback = {@localWriteBandwidthProp, this, s};
h4.FocusLostCallback = {@localWriteBandwidthProp, this, s};

s.PadeOrderListener = handle.listener(this,this.findprop('PadeOrderSelectionData'),'PropertyPostSet',{@localReadProp,s,this});

s.TargetListener = handle.listener(this,this.findprop('Target'),'PropertyPostSet',{@localAddListener,this,s});

%---Store java handles
set(Main,'UserData',s);


function localAddListener(es,ed,this,s)
if ~isempty(this.Target)
    this.Listeners.addListeners(handle.listener(this.Target.LoopData,'ConfigChanged',{@localUpdateText,s,this}));
end

%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s,this) %#ok<INUSL>
% Update GUI when property changes
s.PadeOrder.setEnabled(~this.PadeOrderSelectionData.UseBandwidth)
s.PadeOrder.setText(num2str(this.PadeOrderSelectionData.PadeOrder))
s.PadeRadioButton.setSelected(~this.PadeOrderSelectionData.UseBandwidth)
s.Bandwidth.setText(num2str(this.PadeOrderSelectionData.Bandwidth))
s.Bandwidth.setEnabled(this.PadeOrderSelectionData.UseBandwidth)
s.BandwidthRadioButton.setSelected(this.PadeOrderSelectionData.UseBandwidth)
s.BandwidthPadeLabel.setText(sprintf('(%s %d)',ctrlMsgUtils.message('Control:compDesignTask:strPadeLabel'), localComputePadeOrder(this)))
s.BandwidthPadeLabel.setEnabled(this.PadeOrderSelectionData.UseBandwidth)



function localUpdateText(es,ed,s,this)

PadeOrder = localComputePadeOrder(this);
s.BandwidthPadeLabel.setText(sprintf('(%s %d)',ctrlMsgUtils.message('Control:compDesignTask:strPadeLabel'), PadeOrder))
this.PadeOrder = PadeOrder;

%%%%%%%%%%%%%%%%%%
% localWritePadeProp %
%%%%%%%%%%%%%%%%%%
function localWritePadeProp(eventSrc,eventData,this) %#ok<INUSL>
% Update property when GUI changes
% Need to make sure data is an integer
value = str2num(eventSrc.getText);
if isscalar(value) && isfinite(value) && ~mod(value,1) && (value>=0)
    this.PadeOrderSelectionData.PadeOrder = value;
    this.PadeOrder = value;
else
    eventSrc.setText(num2str(this.PadeOrderSelectionData.PadeOrder));
end
    
%%%%%%%%%%%%%%%%%%
% localWriteBandwidthProp %
%%%%%%%%%%%%%%%%%%
function localWriteBandwidthProp(eventSrc,eventData,this,s) %#ok<INUSL>
% Update property when GUI changes
value = str2num(eventSrc.getText);
if isscalar(value) && isfinite(value) && (value>0)
    this.PadeOrderSelectionData.Bandwidth = value;
    PadeOrder = localComputePadeOrder(this);
    this.PadeOrder = PadeOrder;
    s.BandwidthPadeLabel.setText(sprintf('(%s %d)',...
        ctrlMsgUtils.message('Control:compDesignTask:strPadeLabel'), PadeOrder))
else
    eventSrc.setText(num2str(this.PadeOrderSelectionData.Bandwidth));
end


function localPadeRadioButton(eventSrc,eventData,this) %#ok<INUSL>
% Update property when GUI changes
% Need to make sure data is an integer
this.PadeOrderSelectionData.UseBandwidth = false;
this.PadeOrder = this.PadeOrderSelectionData.PadeOrder;

function localBandwidthRadioButton(eventSrc,eventData,this) %#ok<INUSL>
% Update property when GUI changes
PadeOrder = localComputePadeOrder(this);
this.PadeOrder = PadeOrder;
this.PadeOrderSelectionData.UseBandwidth = true;

function PadeOrder = localComputePadeOrder(this)

% Compute Pade Order
if isempty(this.Target)
    PadeOrder = 0;
else
    PadeOrder = utComputePadeOrder(this.Target, this.PadeOrderSelectionData.Bandwidth);
end







function createLayout(this)
% create layout for saturation/deadzone editor dialog

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:08:11 $

import javax.swing.*;
import java.awt.*;
import java.awt.color.*;
import javax.swing.border.*;
import com.mathworks.mwswing.*;

Dlg = MJDialog(this.Handles.Owner, this.getDialogName, true); %modal
Dlg.setName('nlident:deadsatshapeeditor:MainDialog');

Pt = this.Handles.Owner.getLocation;
Dlg.setLocation(Pt.getX+40, Pt.getY+40);
Dlg.setSize(Dimension(450,300));

%{
m = this.Panel.NlhwModel;
if this.Parameters.isInput
    str0 = sprintf('input channel: %s',m.uname{this.Parameters.Index});
else
    str0 = sprintf('output channel: %s',m.yname{this.Parameters.Index});
end
istr = sprintf('Specify %s limits on the %s. Enter [] to use default values.',...
    this.getNLName,str0);
%}

ilab = MJLabel('Note: ');
iPanel = MJPanel(GridLayout(0,1));
iPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
iPanel.add(ilab);

rOne = MJRadioButton(['One-sided ',this.getNLName]);
rOne.setName('nlident:deadsatshapeeditor:one-sided-radio');
rTwo = MJRadioButton(['Two-sided ',this.getNLName],true);
rTwo.setName('nlident:deadsatshapeeditor:two-sided-radio');
RadioBtnGroup1 = ButtonGroup;
RadioBtnGroup1.add(rOne);
RadioBtnGroup1.add(rTwo);

RadioPanel1 = MJPanel;
RadioPanel1.setLayout(BoxLayout(RadioPanel1, BoxLayout.Y_AXIS));
RadioPanel1.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
RadioPanel1.add(rTwo);
RadioPanel1.add(Box.createVerticalStrut(5));
RadioPanel1.add(rOne);

rUp = MJRadioButton('Upper limit only',true);
rUp.setName('nlident:deadsatshapeeditor:upper-only-radio');
rLow = MJRadioButton('Lower limit only');
rLow.setName('nlident:deadsatshapeeditor:lower-only-radio');
RadioBtnGroup2 = ButtonGroup;
RadioBtnGroup2.add(rUp);
RadioBtnGroup2.add(rLow);

RadioPanel2 = MJPanel;
RadioPanel2.setLayout(BoxLayout(RadioPanel2, BoxLayout.Y_AXIS));
RadioPanel2.setBorder(BorderFactory.createEmptyBorder(0,25,5,5));
RadioPanel2.add(rUp);
RadioPanel2.add(Box.createVerticalStrut(5));
RadioPanel2.add(rLow);
RadioPanel2.add(Box.createHorizontalGlue);

RadioPanel = MJPanel;
RadioPanel.setLayout(BoxLayout(RadioPanel, BoxLayout.Y_AXIS));
RadioPanel.add(RadioPanel1);
RadioPanel.add(RadioPanel2);
RadioOuterPanel = MJPanel(BorderLayout);
RadioOuterPanel.add(RadioPanel,BorderLayout.WEST);

%todo: disable rUp, rlow
XmaxEdit = MJTextField(this.getStr('up'));
XmaxEdit.setName('nlident:deadsatshapeeditor:upedit');
XminEdit = MJTextField(this.getStr('low'));
XminEdit.setName('nlident:deadsatshapeeditor:lowedit');

uplabel = MJLabel('Upper Limit:');
lowlabel = MJLabel('Lower Limit:');

UpPanel = MJPanel;
UpPanel.setLayout(BoxLayout(UpPanel, BoxLayout.X_AXIS));
UpPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
UpPanel.add(uplabel);
UpPanel.add(Box.createHorizontalStrut(5));
UpPanel.add(XmaxEdit);

LowPanel = MJPanel;
LowPanel.setLayout(BoxLayout(LowPanel, BoxLayout.X_AXIS));
LowPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
LowPanel.add(lowlabel);
LowPanel.add(Box.createHorizontalStrut(5));
LowPanel.add(XminEdit);

% status panel
StatusLabel = MJLabel('');
StatusPanel = MJPanel(GridLayout(0,1));
StatusPanel.setBorder(BorderFactory.createEmptyBorder(3,0,3,0));
StatusLabel.setOpaque(true);
pColor = StatusPanel.getBackground;
StatusLabel.setBackground(pColor.brighter); 
StatusPanel.add(StatusLabel);

EditPanel = MJPanel;
EditPanel.setLayout(BoxLayout(EditPanel, BoxLayout.Y_AXIS));
EditPanel.setBorder(BorderFactory.createEmptyBorder(0,10,0,10));
EditPanel.add(UpPanel);
EditPanel.add(LowPanel);
EditPanel.add(StatusPanel);
EditPanel.add(Box.createVerticalGlue);
EditOuterPanel = MJPanel(BorderLayout);
EditOuterPanel.add(EditPanel,BorderLayout.NORTH);

% buttons
OKBtn = MJButton('OK');
OKBtn.setName('nlident:deadsatshapeeditor:OKBtn');
CancelBtn = MJButton('Cancel');
CancelBtn.setName('nlident:deadsatshapeeditor:CancelBtn');
ApplyBtn = MJButton('Apply');
ApplyBtn.setName('nlident:deadsatshapeeditor:ApplyBtn');
HelpBtn = MJButton('Help');
HelpBtn.setName('nlident:deadsatshapeeditor:HelpBtn');

BtnPanel = MJPanel;
BtnPanel.setLayout(BoxLayout(BtnPanel, BoxLayout.X_AXIS));
BtnPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
BtnPanel.add(Box.createHorizontalGlue);
BtnPanel.add(OKBtn);
BtnPanel.add(Box.createHorizontalStrut(5));
BtnPanel.add(CancelBtn);
BtnPanel.add(Box.createHorizontalStrut(5));
BtnPanel.add(ApplyBtn);
BtnPanel.add(Box.createHorizontalStrut(5));
BtnPanel.add(HelpBtn);
BtnPanel.add(Box.createHorizontalStrut(10));

TopPanel = MJPanel;
TopPanel.setLayout(BoxLayout(TopPanel, BoxLayout.Y_AXIS));
TopPanel.setBorder(BorderFactory.createCompoundBorder(...
    BorderFactory.createEmptyBorder(5,5,5,5),...
    BorderFactory.createEtchedBorder));
TopPanel.add(iPanel);
TopPanel.add(RadioOuterPanel);
TopPanel.add(EditOuterPanel);
TopPanel.add(Box.createVerticalGlue);

MainPanel = MJPanel(BorderLayout);
MainPanel.add(TopPanel,BorderLayout.CENTER);
MainPanel.add(BtnPanel,BorderLayout.SOUTH);
Dlg.getContentPane.add(MainPanel);

this.Handles.Dialog = Dlg;
this.Handles.iLabel = ilab;
this.Handles.rTwo = rTwo;
this.Handles.rOne = rOne;
this.Handles.rUp = rUp;
this.Handles.rLow = rLow;
this.Handles.StatusLabel = StatusLabel;
this.Handles.XmaxEdit = XmaxEdit;
this.Handles.XminEdit = XminEdit;
this.Handles.OKBtn = OKBtn;
this.Handles.CancelBtn = CancelBtn;
this.Handles.ApplyBtn = ApplyBtn;
this.Handles.HelpBtn = HelpBtn;
% this.Handles.RadioGroup1 = RadioBtnGroup1;
% this.Handles.RadioGroup2 = RadioBtnGroup2;

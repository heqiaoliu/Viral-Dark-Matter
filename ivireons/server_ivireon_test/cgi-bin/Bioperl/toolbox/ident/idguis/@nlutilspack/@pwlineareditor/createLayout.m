function createLayout(this)
% create layout for pwlinear editor dialog

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/09/18 02:08:14 $

import javax.swing.*;
import java.awt.*;
import java.awt.color.*;
import javax.swing.border.*;
import com.mathworks.mwswing.*;

Dlg = MJDialog(this.Handles.Owner, 'Piecewise Linear Breakpoints', true);
Dlg.setName('nlident:pwlinearshapeeditor:MainDialog');
Pt = this.Handles.Owner.getLocation;
Dlg.setLocation(Pt.getX+40, Pt.getY+40);
Dlg.setSize(Dimension(470,320));

ilab1 = MJLabel('Number of break points: ');
iPanel1 = MJPanel(GridLayout(0,1));
iPanel1.setBorder(BorderFactory.createEmptyBorder(5,5,5,10));
iPanel1.add(ilab1);

ilab2a = MJLabel('Specify break point locations and the corresponding nonlinearity values.');
ilab2b = MJLabel('Use [] for defaults.');
iPanel2 = MJPanel(GridLayout(2,1));
iPanel2.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
iPanel2.add(ilab2a);
iPanel2.add(ilab2b);

iPanel = MJPanel;
iPanel.setLayout(BoxLayout(iPanel, BoxLayout.Y_AXIS));
iPanel.add(iPanel1);
iPanel.add(iPanel2);
iPanel.add(Box.createVerticalGlue);

rx = MJRadioButton('Break point locations only',true);
rx.setName('nlident:pwlinearshapeeditor:xonly');
ry = MJRadioButton('Break point locations as well as nonlinearity values');
ry.setName('nlident:pwlinearshapeeditor:x&y');
RadioBtnGroup = ButtonGroup;
RadioBtnGroup.add(rx);
RadioBtnGroup.add(ry);

RadioPanel = MJPanel;
RadioPanel.setLayout(BoxLayout(RadioPanel, BoxLayout.Y_AXIS));
RadioPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
RadioPanel.add(rx);
RadioPanel.add(Box.createVerticalStrut(5));
RadioPanel.add(ry);
RadioPanel.add(Box.createHorizontalGlue);
RadioOuterPanel = MJPanel(BorderLayout);
RadioOuterPanel.add(RadioPanel,BorderLayout.WEST);


XEdit = MJTextField(''); %this.getStr('x')
XEdit.setName('nlident:pwlinearshapeeditor:xedit');
YEdit = MJTextField(''); %this.getStr('y')
YEdit.setName('nlident:pwlinearshapeeditor:yedit');

xlab =  MJLabel(sprintf('Break points:%s','          '));
ylab =  MJLabel('Nonlinearity values:');
xlabpanel = MJPanel(GridLayout(0,1));
xlabpanel.add(xlab);
ylabpanel = MJPanel(GridLayout(0,1));
ylabpanel.add(ylab);

XPanel = MJPanel;
XPanel.setLayout(BoxLayout(XPanel, BoxLayout.X_AXIS));
XPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
XPanel.add(xlabpanel);
XPanel.add(Box.createHorizontalStrut(5));
XPanel.add(XEdit);

YPanel = MJPanel;
YPanel.setLayout(BoxLayout(YPanel, BoxLayout.X_AXIS));
YPanel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
YPanel.add(ylabpanel);
YPanel.add(Box.createHorizontalStrut(5));
YPanel.add(YEdit);

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
EditPanel.add(XPanel);
EditPanel.add(YPanel);
EditPanel.add(StatusPanel);
EditPanel.add(Box.createVerticalGlue);
EditOuterPanel = MJPanel(BorderLayout);
EditOuterPanel.add(EditPanel,BorderLayout.NORTH);

% buttons
OKBtn = MJButton('OK');
OKBtn.setName('nlident:pwlinearshapeeditor:OKBtn');
CancelBtn = MJButton('Cancel');
CancelBtn.setName('nlident:pwlinearshapeeditor:CancelBtn');
ApplyBtn = MJButton('Apply');
ApplyBtn.setName('nlident:pwlinearshapeeditor:ApplyBtn');
HelpBtn = MJButton('Help');
HelpBtn.setName('nlident:pwlinearshapeeditor::HelpBtn');

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
this.Handles.iLabel = ilab1;
this.Handles.rx = rx;
this.Handles.ry = ry;
this.Handles.StatusLabel = StatusLabel;
this.Handles.XEdit = XEdit;
this.Handles.YEdit = YEdit;
this.Handles.OKBtn = OKBtn;
this.Handles.CancelBtn = CancelBtn;
this.Handles.ApplyBtn = ApplyBtn;
this.Handles.HelpBtn = HelpBtn;

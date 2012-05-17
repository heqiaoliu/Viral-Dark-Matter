function createLayout(this)
% create layout for poly1d editor dialog

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:22:01 $

import javax.swing.*;
import java.awt.*;
import java.awt.color.*;
import javax.swing.border.*;
import com.mathworks.mwswing.*;

Dlg = MJDialog(this.Handles.Owner, 'One-dimensional Polynomial Coefficients', true);
Dlg.setName('nlident:poly1deditor:MainDialog');
Pt = this.Handles.Owner.getLocation;
Dlg.setLocation(Pt.getX+40, Pt.getY+40);
Dlg.setSize(Dimension(500,200));

ilab1 = MJLabel('Degree of polynomial: ');
iPanel1 = MJPanel(GridLayout(0,1));
iPanel1.setBorder(BorderFactory.createEmptyBorder(5,5,5,10));
iPanel1.add(ilab1);

ilab2a = MJLabel('Specify initial coefficient values as a row vector of N+1 real, finite values (N = polynomial degree).');
ilab2b = MJLabel('Use [] for default.');
iPanel2 = MJPanel(GridLayout(2,1));
iPanel2.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
iPanel2.add(ilab2a);
iPanel2.add(ilab2b);

iPanel = MJPanel;
iPanel.setLayout(BoxLayout(iPanel, BoxLayout.Y_AXIS));
iPanel.add(iPanel1);
iPanel.add(iPanel2);
iPanel.add(Box.createVerticalGlue);

CoeffEdit = MJTextField(''); 
CoeffEdit.setName('nlident:poly1deditor:coeffedit');

lab =  MJLabel(sprintf('Coefficients:%s','          '));
labpanel = MJPanel(GridLayout(0,1));
labpanel.add(lab);

Panel = MJPanel;
Panel.setLayout(BoxLayout(Panel, BoxLayout.X_AXIS));
Panel.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
Panel.add(labpanel);
Panel.add(Box.createHorizontalStrut(5));
Panel.add(CoeffEdit);

% status panel
StatusLabel = MJLabel('');
StatusPanel = MJPanel(GridLayout(0,1));
StatusPanel.setBorder(BorderFactory.createEmptyBorder(3,0,3,0));
StatusLabel.setOpaque(true);
pColor = Color(0.9961,0.4353,0.2784);        % StatusPanel.getBackground;
StatusLabel.setBackground(pColor); % pColor.brighter 
StatusPanel.add(StatusLabel);

EditPanel = MJPanel;
EditPanel.setLayout(BoxLayout(EditPanel, BoxLayout.Y_AXIS));
EditPanel.setBorder(BorderFactory.createEmptyBorder(0,10,0,10));
EditPanel.add(Panel);
EditPanel.add(StatusPanel);
EditPanel.add(Box.createVerticalGlue);
EditOuterPanel = MJPanel(BorderLayout);
EditOuterPanel.add(EditPanel,BorderLayout.NORTH);

% buttons
OKBtn = MJButton('OK');
OKBtn.setName('nlident:poly1deditor:OKBtn');
CancelBtn = MJButton('Cancel');
CancelBtn.setName('nlident:poly1deditor:CancelBtn');
ApplyBtn = MJButton('Apply');
ApplyBtn.setName('nlident:poly1deditor:ApplyBtn');
HelpBtn = MJButton('Help');
HelpBtn.setName('nlident:poly1deditor:HelpBtn');

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
TopPanel.add(EditOuterPanel);
TopPanel.add(Box.createVerticalGlue);

MainPanel = MJPanel(BorderLayout);
MainPanel.add(TopPanel,BorderLayout.CENTER);
MainPanel.add(BtnPanel,BorderLayout.SOUTH);
Dlg.getContentPane.add(MainPanel);

this.Handles.Dialog = Dlg;
this.Handles.iLabel = ilab1;
this.Handles.StatusLabel = StatusLabel;
this.Handles.CoeffEdit = CoeffEdit;
this.Handles.OKBtn = OKBtn;
this.Handles.CancelBtn = CancelBtn;
this.Handles.ApplyBtn = ApplyBtn;
this.Handles.HelpBtn = HelpBtn;

function TabHandles = buildcomptab_PZEditor(Editor)
%BUILDCOMPTAB_PZEDITOR  Builds a tab panel for the PZ Editor

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2010/04/30 00:36:54 $

import java.awt.*;
import javax.swing.* ;

%% Constant definitions
SPACE_CONSTANT = 5;
%Set column size for edit fields in Cards
Columns=1;

%% Build tabbed panel component P1, which shows the list of pzgroups
P1 = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0, SPACE_CONSTANT));
P1.setBorder(BorderFactory.createTitledBorder(xlate(' Dynamics ')));

% Build Table for dynamics
% create the table model
TableModel = com.mathworks.toolbox.control.dialogs.ImportDlgTableModel;
% create the table
Table = javaObjectEDT('com.mathworks.mwswing.MJTable',TableModel);
awtinvoke(Table,'setName(Ljava.lang.String;)','PZTable');
% create the scrollpane
Scrollpane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',Table);
% change table size
awtinvoke(Table,'setPreferredScrollableViewportSize(Ljava.awt.Dimension;)',Dimension(350, 150));
% disable column reordering
awtinvoke(Table.getTableHeader,'setReorderingAllowed(Z)',false); 

% Popup menu to add and delete compensator types
Popup = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu');

% Add PZ menu
MenuItem1 = javaObjectEDT('com.mathworks.mwswing.MJMenu',xlate('Add Pole/Zero'));
Popup.add(MenuItem1);

% Menu items under "Add Pole/Zero" Menu
Item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Real Pole'));
Item2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Complex Pole'));
Item3 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Integrator'));

Item4 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Real Zero'));
Item5 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Complex Zero'));
Item6 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Differentiator'));

Item7 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Lead'));
Item8 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Lag'));
Item9 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Notch'));

MenuItem1.add(Item1);
MenuItem1.add(Item2);
MenuItem1.add(Item3);
MenuItem1.addSeparator;
MenuItem1.add(Item4);
MenuItem1.add(Item5);
MenuItem1.add(Item6);
MenuItem1.addSeparator;
MenuItem1.add(Item7);
MenuItem1.add(Item8);
MenuItem1.add(Item9);

% Set Menu Item Callbacks
h = handle(Item1,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'RealPole'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'RealPole'};
h = handle(Item2,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'ComplexPole'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'ComplexPole'};
h = handle(Item3,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'Integrator'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'Integrator'};
h = handle(Item4,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'RealZero'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'RealZero'};
h = handle(Item5,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'ComplexZero'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'ComplexZero'};
h = handle(Item6,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'Differentiator'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'Differentiator'};
h = handle(Item7,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'Lead'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'Lead'};
h = handle(Item8,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'Lag'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'Lag'};
h = handle(Item9,'callbackproperties');
h.MouseClickedCallback = {@LocalAddPZ Editor 'Notch'};
h.ActionPerformedCallback = {@LocalAddPZ Editor 'Notch'};

% Delete PZ menu
MenuItem2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Delete Pole/Zero'));
Popup.add(MenuItem2);
h = handle(MenuItem2,'callbackproperties');
h.MouseClickedCallback = {@LocalDeletePZ Editor};
h.ActionPerformedCallback = {@LocalDeletePZ Editor};
awtinvoke(MenuItem2,'setEnabled(Z)',false);

% store handles
MenuItems = [Item1; Item2; Item3; Item4; Item5; Item6; Item7; Item8; Item9; MenuItem1; MenuItem2; Popup];

% Callbacks for both mouse pressed and released for cross platform look 
% and feel for activating popup menus
h = handle(Table, 'callbackproperties' );
h.MousePressedCallback = {@LocalMaybeShowPopup, Editor};
h.MouseReleasedCallback = {@LocalMaybeShowPopup, Editor};
h = handle(Scrollpane, 'callbackproperties' );
h.MousePressedCallback = {@LocalMaybeShowPopup, Editor};
h.MouseReleasedCallback = {@LocalMaybeShowPopup, Editor};

% create instruction
Label3 = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
    sprintf('Right-click to add or delete poles/zeros'));

% add panels into P1
P1.add(Scrollpane, BorderLayout.CENTER);
P1.add(Label3, BorderLayout.SOUTH);

%% Build tabbed panel component P2, which shows the details of each pzgroup
P2 = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(0,SPACE_CONSTANT));
title = BorderFactory.createEmptyBorder(0,3,0,3);
P2.setBorder(title);

% 1. Build card component for edit of complex pole/zero
CardCPZ = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CardCPZ.setName('Complex Pole/Zero Card')
title = BorderFactory.createTitledBorder(xlate(' Edit Selected Dynamics '));
CardCPZ.setBorder(title);

GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.anchor = GridBagConstraints.EAST;

% Column 1
GBc.gridx = 0;
GBc.anchor = GridBagConstraints.EAST;

LabelC1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Natural Frequency'));
GBc.gridy = 0;
CardCPZ.add(LabelC1, GBc);

LabelC2 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Damping'));
GBc.gridy = 1;
CardCPZ.add(LabelC2, GBc)

LabelC3 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Real Part'));
GBc.gridy = 2;
CardCPZ.add(LabelC3, GBc);

LabelC4 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Imaginary Part'));
GBc.gridy = 3;
CardCPZ.add(LabelC4, GBc);

% Column 2
GBc.gridx = 1;
GBc.ipadx = 100;
GBc.anchor = GridBagConstraints.WEST;

EditCWn = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditCWn.setName('CWn');
GBc.gridy = 0;
CardCPZ.add(EditCWn, GBc);

EditCZeta = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditCZeta.setName('CZeta');
GBc.gridy = 1;
CardCPZ.add(EditCZeta, GBc);

EditCR = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditCR.setName('CReal');
GBc.gridy = 2;
CardCPZ.add(EditCR, GBc)

EditCI = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditCI.setName('CImag');
GBc.gridy = 3;
CardCPZ.add(EditCI, GBc);

% 2. Build card component for edit of Real pole/zero
CardRPZ = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CardRPZ.setName('Real Pole/Zero Card')
title = BorderFactory.createTitledBorder(xlate(' Edit Selected Dynamics '));
CardRPZ.setBorder(title);

GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.anchor = GridBagConstraints.EAST;

% Column 1
GBc.gridx = 0;
GBc.anchor = GridBagConstraints.EAST;

LabelR1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Location'));
GBc.gridy = 0;
CardRPZ.add(LabelR1, GBc);

% Column 2
GBc.gridx = 1;
GBc.ipadx = 100;
GBc.anchor = GridBagConstraints.WEST;

EditR1 = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditR1.setName('Real');
GBc.gridy = 0;
CardRPZ.add(EditR1, GBc);

% 3. Build card panel component for edit of Lead Lag
CardLLPZ = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CardLLPZ.setName('Lead/Lag Pole/Zero Card')
title = BorderFactory.createTitledBorder(xlate(' Edit Selected Dynamics '));
CardLLPZ.setBorder(title);

GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.anchor = GridBagConstraints.EAST;

% Column 1
GBc.gridx = 0;
GBc.anchor = GridBagConstraints.EAST;

LabelLL1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Real Zero'));
GBc.gridy = 0;
CardLLPZ.add(LabelLL1, GBc);

LabelLL2 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Real Pole'));
GBc.gridy = 1;
CardLLPZ.add(LabelLL2, GBc)

LabelLL3 = javaObjectEDT('com.mathworks.mwswing.MJLabel',xlate('<HTML> Max Delta <br>Phase (deg)'));
GBc.gridy = 2;
CardLLPZ.add(LabelLL3, GBc)

LabelLL4 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('at Frequency'));
GBc.gridy = 3;
CardLLPZ.add(LabelLL4, GBc)

% Column 2
GBc.gridx = 1;
GBc.ipadx = 100;
GBc.anchor = GridBagConstraints.WEST;

EditLLZ = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditLLZ.setName('LLZero');
GBc.gridy = 0;
CardLLPZ.add(EditLLZ, GBc);

EditLLP = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditLLP.setName('LLPole');
GBc.gridy = 1;
CardLLPZ.add(EditLLP, GBc);

EditLLPhase = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditLLPhase.setName('LLPhase');
GBc.gridy = 2;
CardLLPZ.add(EditLLPhase, GBc);

EditLLFreq = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditLLFreq.setName('LLFreq');
GBc.gridy = 3;
CardLLPZ.add(EditLLFreq, GBc);

% 4. Build panel component for edit of Notch
CardNotch = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CardNotch.setName('Notch Card')
title = BorderFactory.createTitledBorder(xlate(' Edit Selected Dynamics '));
CardNotch.setBorder(title);

GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.anchor = GridBagConstraints.EAST;

% Column 1
GBc.gridx = 0;
GBc.anchor = GridBagConstraints.EAST;

LabelN1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Natural Frequency'));
GBc.gridy = 0;
CardNotch.add(LabelN1, GBc);

LabelN2 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Damping (Zero)'));
GBc.gridy = 1;
CardNotch.add(LabelN2, GBc)

LabelN3 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Damping (Pole)'));
GBc.gridy = 2;
CardNotch.add(LabelN3, GBc);

LabelN4 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Notch Depth (dB)'));
GBc.gridy = 3;
CardNotch.add(LabelN4, GBc);

LabelN5 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Notch Width (Log)'));
GBc.gridy = 4;
CardNotch.add(LabelN5, GBc);

% Column 2
GBc.gridx = 1;
GBc.ipadx = 100;
GBc.anchor = GridBagConstraints.WEST;

EditNWn = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditNWn.setName('NWn');
GBc.gridy = 0;
CardNotch.add(EditNWn, GBc);

EditNZZeta = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditNZZeta.setName('NZeroZeta');
GBc.gridy = 1;
CardNotch.add(EditNZZeta, GBc);

EditNPZeta = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditNPZeta.setName('NPoleZeta');
GBc.gridy = 2;
CardNotch.add(EditNPZeta, GBc)

EditNDepth = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditNDepth.setName('NDepth');
GBc.gridy = 3;
CardNotch.add(EditNDepth, GBc)

EditNWidth = javaObjectEDT('com.mathworks.mwswing.MJTextField',Columns);
EditNWidth.setName('NWidth');
GBc.gridy = 4;
CardNotch.add(EditNWidth, GBc)

% 5. Build card component for blank when multi-row or no row selected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CardBlank = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CardBlank.setName('Blank Card')
title = BorderFactory.createTitledBorder(xlate(' Edit Selected Dynamics '));
CardBlank.setBorder(title);
Label15 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Select a single row to edit values'));

GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 0;
CardBlank.add(Label15, GBc);

% 6. Make Cardlayout panel for pzgroup types
PCard = javaObjectEDT('com.mathworks.mwswing.MJPanel',CardLayout);
PCard.add(CardBlank, 'Blank')
PCard.add(CardCPZ, 'Complex')
PCard.add(CardRPZ, 'Real')
PCard.add(CardLLPZ, 'LeadLag')
PCard.add(CardNotch, 'Notch')

% add to P2
P2.add(PCard, BorderLayout.CENTER);

%% Create desired layout spacing for gui
PTab1 = javaObjectEDT('com.mathworks.mwswing.MJPanel');
PTab1.setLayout(BoxLayout(PTab1, BoxLayout.X_AXIS));
PTab1.add(Box.createRigidArea(Dimension(10,0)));
PTab1.add(P1);
PTab1.add(Box.createRigidArea(Dimension(20,0)));
PTab1.add(P2);
PTab1.add(Box.createRigidArea(Dimension(10,0)));
PTab = javaObjectEDT('com.mathworks.mwswing.MJPanel');
PTab.setLayout(BoxLayout(PTab, BoxLayout.Y_AXIS));
PTab.add(Box.createRigidArea(Dimension(0,10)));
PTab.add(PTab1);
PTab.add(Box.createRigidArea(Dimension(0,10)));
PTab.setName('PZPanel');

%% set table row selection listener
SelectionModel = awtinvoke(Table,'getSelectionModel()');
h = handle(SelectionModel, 'callbackproperties' );
h.ValueChangedCallback = {@LocalUpdateTarget Editor};

% Handles to tab panel items
TabHandles = struct(...
    'PTab', PTab, ...
    'Table', Table, ...
    'TableModel', TableModel, ...
    'SelectionModel', SelectionModel, ...
    'PCard', PCard, ...
    'EditR1', EditR1, ...
    'EditCWn', EditCWn, ...
    'EditCZeta', EditCZeta, ...
    'EditCR', EditCR, ...
    'EditCI', EditCI, ...
    'EditLLZ', EditLLZ, ...
    'EditLLP', EditLLP, ...
    'EditLLPhase', EditLLPhase, ...
    'EditLLFreq', EditLLFreq, ...
    'EditNWn', EditNWn, ...
    'EditNZZeta', EditNZZeta, ...
    'EditNPZeta', EditNPZeta, ...
    'EditNDepth', EditNDepth, ...
    'EditNWidth', EditNWidth, ...
    'Scrollpane', Scrollpane, ...
    'DeleteMenu', MenuItem2, ...
    'MenuItems', MenuItems, ...
    'MISC', [Scrollpane; P1],...
    'Popup', Popup);

%-------------------------Callback Functions------------------------

% ------------------------------------------------------------------------%
% Function: LocalUpdateTarget
% Purpose:  Update index in class data to pzgroup selected
% ------------------------------------------------------------------------%
function LocalUpdateTarget(hsrc, event, Editor)

Table = Editor.Handles.PZTabHandles.Table;
% drawnow; % Used to prevent incorrect ordering of callback processing
if ~event.getValueIsAdjusting
    Editor.idxPZ = Table.getSelectedRows + 1;  % java to matlab
    % indexing
    if isVisible(Editor)
       Editor.showpzeditcard;
    end
end


% ------------------------------------------------------------------------%
% Function: LocalMaybeShowPopup
% Purpose:  Callback for displaying add/delete pzgroup popup menu
% ------------------------------------------------------------------------%
function LocalMaybeShowPopup(hSrc, hData, Editor)
if hData.isPopupTrigger
    popup = Editor.Handles.PZTabHandles.Popup;
    awtinvoke(popup,'show(Ljava.awt.Component;II)', hData.getSource, hData.getX, hData.getY);
    awtinvoke(popup,'repaint()');
end


% ------------------------------------------------------------------------%
% Function: LocalDeletePZ
% Purpose:  Callback to delete selected pzgroups
% ------------------------------------------------------------------------%
function LocalDeletePZ(hSrc, hData, Editor)
Editor.deletepz;


% ------------------------------------------------------------------------%
% Function: LocalAddPZ
% Purpose:  Callback to add a pzgroup
% ------------------------------------------------------------------------%
function LocalAddPZ(hSrc, hData, Editor, Type)
Editor.addpz(Type)


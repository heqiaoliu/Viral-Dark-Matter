function Handles = buildcompdisppanel(Editor)
%BUILDCOMPTAB_PZEDITOR  Builds a tab panel for the Parameter Editor

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2008/12/04 22:24:26 $

import java.awt.*;
import javax.swing.* ;


%% Constant definitions
SPACE_CONSTANT = 5;
CompList = Editor.CompList;
GainList = Editor.GainList;  

%% Create the combo box for all the non-gain compensators plus 'all gain
% blocks'
ComboAll = javaObjectEDT('com.mathworks.toolbox.control.util.MJComboBoxForLongStrings');
ComboAll.setName('ComponentComboPZ')
for ct = 1:length(CompList)
    if isempty(CompList(ct).Name)
        ComboAll.addItem(CompList(ct).Identifier);
    else
        ComboAll.addItem(CompList(ct).Name);
    end
end
if ~isempty(GainList)
    if length(GainList)==1
        if isempty(GainList.Name)
            ComboAll.addItem(GainList.Identifier);
        else
            ComboAll.addItem(GainList.Name);
        end
    else
        ComboAll.addItem(sprintf('All Gain Blocks'));
    end
end
ComboAll.setPreferredSize(Dimension(100,ComboAll.getPreferredSize.getHeight));
% set up call back
h = handle(ComboAll,'callbackproperties');
listener = handle.listener(h,'ActionPerformed',{@localCompChange Editor});

%% Create label and strip
PZLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel','', SwingConstants.LEFT);
PZStrip = javaObjectEDT('com.mathworks.mwswing.MJScrollStrip', ...
    SwingConstants.HORIZONTAL, PZLabel, true);

%% Create compensator selection panel: Combopanel
% insets: top, left, bottom and right
Combopanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
Combopanel.setBorder(BorderFactory.createTitledBorder(xlate(' Compensator ')));

% Add combo box to Combopanel
c = GridBagConstraints;
c.anchor  = GridBagConstraints.WEST;
c.fill    = GridBagConstraints.HORIZONTAL;
c.insets  = Insets(0,SPACE_CONSTANT,SPACE_CONSTANT,SPACE_CONSTANT);
c.weightx = 0.2;
c.weighty = 0;
Combopanel.add(ComboAll,c);

% Add '=' sign to Combopanel
c.insets  = Insets(0,0,SPACE_CONSTANT,SPACE_CONSTANT);
c.weightx = 0;
GainLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('='));
Combopanel.add(GainLabel,c);

% Add gain editor to Combopanel
GainEditor = javaObjectEDT('com.mathworks.mwswing.MJTextField');
GainEditor.setPreferredSize(Dimension(60,GainEditor.getPreferredSize.getHeight));
% set up call back
h = handle(GainEditor,'callbackproperties');
h.ActionPerformedCallback = {@LocalGainChange Editor};
h.FocusLostCallback = {@LocalGainChange Editor};
c.weightx = 0.2;
Combopanel.add(GainEditor,c);

% Add 'x'
c.weightx = 0;
MultiplyLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('x'));
Combopanel.add(MultiplyLabel,c);

% Add PZ display panel to the Combopanel
c.fill      = GridBagConstraints.BOTH;
c.weightx   = 1;
c.weighty   = 1;
Combopanel.add(PZStrip,c);

% Handles to tab panel items
Handles = struct('Combopanel',     Combopanel, ...
                 'CompComboBox',   ComboAll, ...
                 'CompComboBoxListener',listener, ...
                 'CompGainEditor', GainEditor, ...
                 'CompGainLabel',  GainLabel, ...
                 'MultiplyLabel',  MultiplyLabel, ...                 
                 'CompPZLabel',    PZLabel);

%-------------------------Callback Functions------------------------

%-------------------------------------------------------------------------%
% Function: LocalCompChange
% Abstract: Update two tabs when users switch the compensator from one to
% another
%-------------------------------------------------------------------------%
function localCompChange(es,ed,Editor)
choice = awtinvoke(java(es),'getSelectedIndex()')+1;
if choice>0
    Editor.idxCold = Editor.idxC;
    Editor.idxC = choice;
    Editor.idxPZ = awtinvoke(Editor.Handles.PZTabHandles.Table,'getSelectedRows()') + 1;  % java to matlab indexing
    Editor.refreshpanel;
end

% ------------------------------------------------------------------------%
% Function: LocalGainChange
% Purpose:  Callback for editing of gain field
% ------------------------------------------------------------------------%
function LocalGainChange(es,ed,Editor)

idxC = Editor.idxC;
EditG1 = java(es);
PrecisionFormat = Editor.PrecisionFormat;
isfocusevent = isa(ed, 'java.awt.event.FocusEvent');
EditG1Text = awtinvoke(EditG1,'getText()');
EditG1TextOld = Editor.GainCache; % Previous value

% Error handling
if ~(strcmp(EditG1Text, EditG1TextOld) && isfocusevent)
    try
        newgain = eval(EditG1Text);
        if isreal(newgain) && isfinite(newgain) % zero gain is allowed
            
            EventMgr = Editor.Parent.EventManager;
            T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Gain'),...
                'OperationStore','on','InverseOperationStore','on');
            
            Editor.CompList(idxC).setFormattedGain(newgain);
            Editor.GainCache = EditG1Text;
            
            EventMgr.record(T);
            % Notify status and history listeners
            Status = sprintf('Edited Gain');
            EventMgr.newstatus(Status);
            EventMgr.recordtxt('history',Status);
            
            % export the data
            Editor.exportdata;
        else
            EditG1Text = sprintf(PrecisionFormat,str2double(EditG1TextOld));
            awtinvoke(EditG1,'setText(Ljava.lang.String;)',EditG1Text);
        end
    catch
        EditG1Text = sprintf(PrecisionFormat,str2double(EditG1TextOld));
        awtinvoke(EditG1,'setText(Ljava.lang.String;)',EditG1Text);
    end
end

function TabHandles = buildcomptab_ParaEditor(Editor)
%BUILDCOMPTAB_PZEDITOR  Builds a tab panel for the Parameter Editor

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2008/12/04 22:24:38 $

import java.awt.*;
import javax.swing.* ;


%% Build tabbed panel component P1, which displays the parameter table
% Build JAVA Table for dynamics: table, tablemodel and scrollpane in java
Scrollpane = javaObjectEDT('com.mathworks.toolbox.control.sisogui.BlockParameterPanel');
% get handles to table and tablemodel
Table = javaObjectEDT(Scrollpane.Table);
awtinvoke(Table,'setName(Ljava.lang.String;)','ParaTable');
TableModel = Scrollpane.TableModel;
% Disable table column reordering
Table.getTableHeader.setReorderingAllowed(false); 
Table.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
% set instruction
awtinvoke(Scrollpane.Instruct,'setText(Ljava/lang/String;)',...
    java.lang.String(xlate('Select a parameter in the table and tune it manually')));
% set tablemodel callback function
h = handle(TableModel, 'callbackproperties' );
h.TableChangedCallback = {@LocalUpdateSetTableData Editor};

% Create desired layout spacing for gui
PTab = javaObjectEDT('com.mathworks.mwswing.MJPanel');
PTab.setName('ParaPanel');
PTab.setLayout(BoxLayout(PTab, BoxLayout.Y_AXIS));
tmpBox = javaMethodEDT('createRigidArea','javax.swing.Box',Dimension(0,10));
PTab.add(tmpBox);
% add scrollpane to panel
PTab.add(Scrollpane, BorderLayout.CENTER);

% Handles to tab panel items
TabHandles = struct(...
    'PTab', PTab, ...
    'Scrollpane', Scrollpane, ...
    'TableModel', TableModel, ...
    'Table', Table);

% ------------------------------------------------------------------------%
%% LocalUpdateSetTableData - Callback for the updating parameter table data
% ------------------------------------------------------------------------%
function LocalUpdateSetTableData(hsrc, event, Editor)

% React only to fireTableRowUpdated(row, row);
col = event.getColumn;
if col == -1
    FirstRow = awtinvoke(event,'getFirstRow');
    LastRow = awtinvoke(event,'getLastRow');
    if FirstRow == LastRow
        data = Editor.Handles.ParaTabHandles.TableModel.getData;
        if Editor.idxC<=length(Editor.CompList)
            Editor.setTableData(data,Editor.idxC,FirstRow+1);
        else
            Editor.setTableDataGainList(data,FirstRow+1);
        end
    end
end



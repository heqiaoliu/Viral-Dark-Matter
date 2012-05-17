function axespanel(h,view,type,varargin)

% Copyright 2004-2008 The MathWorks, Inc.

import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.table.*
import java.awt.*;
import com.mathworks.page.utils.VertFlowLayout;
import com.mathworks.toolbox.timeseries.*;

% Method which builds/populates the axes panel on the Property Editor

% Assemble the axes table data by traversing the axesgrid, finding its
% position, and writing the corresponding row

if strcmp(type,'Y')
    tableData = cell([view.AxesGrid.size(1),4]);
    for k=1:view.Axesgrid.size(1) 
        ylims = view.Axesgrid.getylim(k);
        tableData(k,:) = {view.AxesGrid.RowLabel{k}, ...
            view.Axesgrid.YlimMode{k},ylims(1),ylims(2)};
    end
else
    tableData = cell([view.AxesGrid.size(2),4]);
    for k=1:view.Axesgrid.size(2)     
        xlims = view.Axesgrid.getxlim(k);
        tableData(k,:) = {view.AxesGrid.ColumnLabel{k}, ...
            view.Axesgrid.XlimMode{k},xlims(1),xlims(2)};
    end    
end

% Find the axes tab
thisTab = h.findtab([type 'Axes']);

% If necessary build the axes tab
if isempty(thisTab)
    % Create the table model   
    tableModel = tsMatlabCallbackTableModel(tableData,...
            {xlate('Title'),xlate('Scaling'),sprintf('%smin',type),sprintf('%smax',type)},...
            'updateAxesTable',{view type}); 

    % Build the axes table
    thisTab.Handles.AxesGridTable = javaObjectEDT('com.mathworks.mwswing.MJTable',tableModel);
    thisTab.Handles.AxesGridTable.setName('AxesGridTable');
    javaMethod('setRowSelectionAllowed',thisTab.Handles.AxesGridTable,true);
    javaMethod('setColumnSelectionAllowed',thisTab.Handles.AxesGridTable,false);
    javaMethod('setAutoResizeMode',thisTab.Handles.AxesGridTable,...
        JTable.AUTO_RESIZE_ALL_COLUMNS);
    sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',...
        thisTab.Handles.AxesGridTable);
    
    % Define the axes panel container
    container = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(5,5));
    javaMethod('add',container,sPanel,BorderLayout.CENTER);
    javaMethod('add',h.Handles.TabPane,sprintf('Define %s Axes Scaling',type),...
        container);

    % Add the help button
    thisTab.Handles.HelpButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
        xlate('Help'));
    set(handle(thisTab.Handles.HelpButton,'callbackproperties'),'ActionPerformedCallback',...
         {@localHelpCallback view});
    
    % If necessary add the log/linear check box, adding the help panel to
    % the east side of the log checkbox
    if nargin>=4
        thisTab.Handles.LogCheckBox = javaObjectEDT('com.mathworks.mwswing.MJCheckBox',...
            varargin{1});
        PNLlogCheck = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(5,10));
        javaMethod('setBorder',PNLlogCheck,BorderFactory.createEmptyBorder(0,5,5,5));
        javaMethod('add',PNLlogCheck,thisTab.Handles.LogCheckBox,BorderLayout.WEST);
        javaMethod('add',PNLlogCheck,thisTab.Handles.HelpButton,BorderLayout.EAST);
        set(handle(thisTab.Handles.LogCheckBox,'callbackproperties'),...
            'ActionPerformedCallback',{@localSetYScale view thisTab.Handles.LogCheckBox});
        javaMethod('setSelected',thisTab.Handles.LogCheckBox,...
            any(strcmp(view.AxesGrid.Yscale,'log')));
        javaMethod('add',container,PNLlogCheck,BorderLayout.SOUTH);
    else % Otherwise add the help button on the east side of the table
        helpPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
        javaMethod('setBorder',helpPanel,BorderFactory.createEmptyBorder(0,0,5,5));
        javaMethod('add',helpPanel,thisTab.Handles.HelpButton,BorderLayout.SOUTH);
        javaMethod('add',container,helpPanel,BorderLayout.EAST);         
    end
    
    % Update the Tabs structure
    thisTab.Name = [type 'Axes'];
    h.Tabs = [h.Tabs; thisTab];
    localSetComboColumnEditor(thisTab);
    
else % Update the table model
    if thisTab.Handles.AxesGridTable.getColumnCount==size(tableData,2) && ...
          thisTab.Handles.AxesGridTable.getRowCount==size(tableData,1)
       for row = 1:size(tableData,1)
           for col=1:size(tableData,2)
               if ischar(tableData{row,col})
                   if ~strcmp(thisTab.Handles.AxesGridTable.getValueAt(row-1,col-1),...
                           tableData{row,col})
                       thisTab.Handles.AxesGridTable.getModel.setValueAtNoCallback(...
                           tableData{row,col},row-1,col-1);
                   end
               elseif isnumeric(tableData{row,col})
                    if thisTab.Handles.AxesGridTable.getValueAt(row-1,col-1)~=...
                           tableData{row,col}
                      thisTab.Handles.AxesGridTable.getModel.setValueAtNoCallback(...
                           tableData{row,col},row-1,col-1);
                   end                  
               end    
                   
           end
       end
    else % Rebuild the table model
         % Create the table model
        tableModel = tsMatlabCallbackTableModel(tableData,...
            {xlate('Title'),xlate('Scaling'),sprintf('%smin',type),sprintf('%smax',type)},...
            'updateAxesTable',{view type});    
        awtinvoke(thisTab.Handles.AxesGridTable,'setModel(Ljavax/swing/table/TableModel;)',...
            tableModel);
        localSetComboColumnEditor(thisTab);
    end
end

function localSetComboColumnEditor(thisTab)

import javax.swing.*;

% Add combo box for 'auto' and 'manual'
tmp = javaObjectEDT('javax.swing.JComboBox');
javaMethod('addItem',tmp,'auto');
javaMethod('addItem',tmp,'manual');
ed = DefaultCellEditor(tmp);
if thisTab.Handles.AxesGridTable.getColumnModel.getColumnCount>=2 % columnModel may not yet be up to date
    javaMethod('setCellEditor',thisTab.Handles.AxesGridTable.getColumnModel.getColumn(1),...
        ed);
end
        
function localSetYScale(es,ed,view,LogCheckBox)

if LogCheckBox.isSelected
    view.AxesGrid.Yscale = 'log';
else
    view.AxesGrid.Yscale = 'linear';
end

function localHelpCallback(es,ed,h)

switch class(h)
    case 'tsguis.timeplot'
        tsDispatchHelp('pe_time_plot','modal')
    case 'tsguis.specplot'
        tsDispatchHelp('pe_periodogram','modal')
    case 'tsguis.histplot'
        tsDispatchHelp('pe_histogram','modal')
    case 'tsguis.xyplot'
        tsDispatchHelp('pe_xy_plot','modal')
    case 'tsguis.corrplot'
        tsDispatchHelp('pe_correlation','modal')
end
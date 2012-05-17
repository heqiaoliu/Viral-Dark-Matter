function charpanel(propeditor,h,charstruct,varargin)   

% Copyright 2004-2006 The MathWorks, Inc.

import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.table.*
import java.awt.*;
import com.mathworks.page.utils.VertFlowLayout;
import com.mathworks.toolbox.timeseries.*;

%% Method which builds/populates the char panel on the Property Editor

%% Assemble the char table data by traversing each characteristic
charlist = charstruct.charlist;
additionalDataProps = charstruct.additionalDataProps;
additionalDataPropDefaults = charstruct.additionalDataPropDefaults;
additionalHeadings = charstruct.additionalHeadings;
waves = h.allwaves;

%% Build char table data 
tableData = cell(0,length(additionalHeadings)+2);
for row=1:size(charlist,1)
    if localfindchar(h,charlist{row,:})           
        varchar = find(waves(1).Characteristics,'Identifier',charlist{row,1});
        if ~isempty(varchar)
            additionalCells = cell(1,length(additionalDataProps)); % Adds cells for start/end time st
            for k=1:length(additionalDataProps)
                additionalCells{k} = sprintf('%0.2g',get(varchar.Data,additionalDataProps{k}));
            end
            tableData = [tableData; ...
                        {strcmp(varchar.Visible,'on'),xlate(charlist{row,1})} additionalCells];
        else 
            tableData = [tableData; ...
                        {false,xlate(charlist{row,1})} additionalDataPropDefaults];
        end
    else
        tableData = [tableData; ...
                     {false,xlate(charlist{row,1})} additionalDataPropDefaults]; %#ok<*AGROW>
    end
end

%% Find the char tab
thisTab = propeditor.findtab('Characteristics');

%% (Re)Create the table model
if ~isempty(thisTab) && isfield(thisTab.Handles,'CharTable') && ...
        ~isempty(thisTab.Handles.CharTable)
    if thisTab.Handles.CharTable.getModel.getDataVector.equals(...
            thisTab.Handles.CharTable.getModel.getDataVector)
        return
    else
        tableModel = thisTab.Handles.CharTable.getModel;
        for row=0:size(tableData,1)-1
            for col=0:size(tableData,2)-1
                tableModel.setValueAtNoCallback(tableData{row+1,col+1},row,col);
            end
        end
    end
else
    if nargin<=3
        tableModel = tsMatlabCallbackTableModel(tableData,...
              [{xlate('Show (y/n)'),xlate('Name')} additionalHeadings],...
              'tsupdateCharTable',{h additionalDataProps [] charlist});
    else
        tableModel = tsMatlabCallbackTableModel(tableData,...
              [{xlate('Show (y/n)'),xlate('Name')} additionalHeadings],...
              'tsupdateCharTable',{h additionalDataProps varargin{1} charlist});
    end
    tableModel.setNoEditCols(1);
end

%% If necessary build the Characteristics tab
if isempty(thisTab)
    % Build the char table    
    thisTab.Handles.CharTable = javaObjectEDT('com.mathworks.mwswing.MJTable',tableModel);
    thisTab.Handles.CharTable.setName('CharTable');
    javaMethod('setReorderingAllowed',thisTab.Handles.CharTable.getTableHeader,false);
    javaMethod('setCellEditor',thisTab.Handles.CharTable.getColumnModel.getColumn(0),...
        DefaultCellEditor(MJCheckBox));
    javaMethod('setCellRenderer',thisTab.Handles.CharTable.getColumnModel.getColumn(0),...
        tsCheckBoxRenderer);
    javaMethod('setRowSelectionAllowed',thisTab.Handles.CharTable,true);
    javaMethod('setColumnSelectionAllowed',thisTab.Handles.CharTable,false);
    javaMethod('setAutoResizeMode',thisTab.Handles.CharTable,...
        JTable.AUTO_RESIZE_ALL_COLUMNS);
    sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',...
        thisTab.Handles.CharTable);    
    
    % Add the help button 
    container = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout(5,5));
    thisTab.Handles.HelpButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
        xlate('Help'));
    set(handle(thisTab.Handles.HelpButton,'callbackproperties'),'ActionPerformedCallback',...
         {@localHelpCallback h});     
    helpPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',BorderLayout);
    javaMethod('setBorder',helpPanel,BorderFactory.createEmptyBorder(5,5,5,5));
    javaMethod('add',helpPanel,thisTab.Handles.HelpButton,BorderLayout.SOUTH);
    javaMethod('add',container,helpPanel,BorderLayout.EAST);   
 
    % Add the char panel container
    javaMethod('add',container,sPanel,BorderLayout.CENTER);
    javaMethod('add',propeditor.Handles.TabPane,...
        xlate('Define Statistical Annotations'),container);
    
    % Update the Tabs structure
    thisTab.Name = 'Characteristics';
    propeditor.Tabs = [propeditor.Tabs; thisTab];
end


function charexists = localfindchar(h,id,dataclass,viewclass)

%% Looks for any existing visible characteristics with identifier id.
%% If one is found chars are created for all waveforms. If one is visible
%% they are all set to visible.

%% Does a char of this type exist?
thischar = [];
waves = h.allwaves;
for k=1:length(waves)
    if ~isempty(waves(k).Characteristics)
         thischar = [thischar(:); ...
             find(waves(k).Characteristics,'Identifier',id)];
    end
end

%% If any chars of this type exist synchronize their visibility
if ~isempty(thischar)
    if any(strcmp(get(thischar,{'Visible'}),'on'))
        h.addchar(id,dataclass,viewclass,'Visible','on'); 
    else
        h.addchar(id,dataclass,viewclass,'Visible','off');
    end
    charexists = true;
else
    charexists = false;
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
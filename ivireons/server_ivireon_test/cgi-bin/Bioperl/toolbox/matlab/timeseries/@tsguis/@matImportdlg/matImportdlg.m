

function this = matImportdlg(parent)
% MATIMPORTDLG is the constructor of the class, which imports time series
% from an mat file into tstool

% Author: Rong Chen 
% Copyright 2005-2009 The MathWorks, Inc.

import javax.swing.*;

this = tsguis.matImportdlg; 
this.Parent = parent;

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
this.defaultPositions;

% -------------------------------------------------------------------------
% initiaize figure window
% -------------------------------------------------------------------------
% create the main figure window
this.Figure = this.Parent.Figure;

% -------------------------------------------------------------------------
% get default background colors for all components
% -------------------------------------------------------------------------
this.DefaultPos.FigureDefaultColor=get(this.Figure,'Color');
this.DefaultPos.EditDefaultColor=[1 1 1];

% -------------------------------------------------------------------------
% initialize if WINDOWS PC OS, get a list of activex server.  if an excel comserver
% exists, try to establish a webcomponent connection as well as initialize
% the activex cotnrol to display, otherwise use uitable for display
% -------------------------------------------------------------------------
% workspace browser
this.Handles.Browser = tsguis.tsvarbrowser;
this.Handles.Browser.typesallowed = ...
    {'double','single','uint8','uint16','unit32','int8','int16','int32','cell'};
this.Handles.Browser.ListSelectionMode = ListSelectionModel.SINGLE_SELECTION;
this.Handles.Browser.open(false);
this.Handles.Browser.javahandle.setName('matImportView');
[this.Handles.jBrowserJUNK, this.Handles.jBrowser] = ...
    javacomponent(this.Handles.Browser.javahandle.getScrollContainer,...
    [0 0 1 1],this.Figure);
set(this.Handles.jBrowser,'Visible','off')
% Assign the copy callback
set(handle(this.Handles.Browser.javahandle.getSelectionModel,'callbackproperties'),...
    'ValueChangedCallback',{@localWorkspaceSelect this});

% -------------------------------------------------------------------------
% other initialization
% -------------------------------------------------------------------------
this.IOData.FileName='';
this.IOData.SelectedRows=[];
this.IOData.SelectedColumns=[];
this.IOData.checkLimit=20;
this.IOData.SelectedVariableInfo=[];

function localWorkspaceSelect(~, eventData, h)

if eventData.getValueIsAdjusting
    return
end

% if no selection
selectedVarInfo = h.Handles.Browser.getSelectedVarInfo;
if isempty(selectedVarInfo)
    h.ClearEditBoxes;
    set(h.Parent.Handles.BTNnext,'Enable','off')
    h.IOData.SelectedVariableInfo = [];
    return
end
set(h.Parent.Handles.BTNnext,'Enable','on')
% update display only if user changes selection in the browser
if ~isequal(h.IOData.SelectedVariableInfo,selectedVarInfo)
    % save the new variable name for future comparison
    h.IOData.SelectedVariableInfo = selectedVarInfo;
    % clear all the selections
    h.ClearEditBoxes;
    % check if the first column or row contains 
    data=h.checkTimeFormat(h.IOData.SelectedVariableInfo.varname,'both','1');
    if isempty(data)
        set(h.Parent.Handles.BTNnext,'Enable','off')
        return
    end        
    % set correct absolute data/time if in the 1st col or row
    if h.IOData.formatcell.columnIsAbsTime>=0
        % update time panel
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
    elseif h.IOData.formatcell.rowIsAbsTime>=0
        % update time panel
        set(h.Handles.COMBdataSample,'Value',2);
        h.TimePanelUpdate('row');
    elseif h.IOData.formatcell.columnIsAbsTime==-1 && size(data,1)>1
        % update time panel
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
    elseif h.IOData.formatcell.rowIsAbsTime==-1 && size(data,2)>1
        % update time panel
        set(h.Handles.COMBdataSample,'Value',2);
        h.TimePanelUpdate('row');
    else
        % update time panel
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
    end
    % set default selection
    set(h.Handles.EDTFROM,'String',['1:' num2str(h.IOData.SelectedVariableInfo.objsize(1))]);
    set(h.Handles.EDTTO,'String',['1:' num2str(h.IOData.SelectedVariableInfo.objsize(2))]);
    h.IOData.SelectedRows=1:h.IOData.SelectedVariableInfo.objsize(1);
    h.IOData.SelectedColumns=1:h.IOData.SelectedVariableInfo.objsize(2);
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        if ~isempty(h.IOData.SelectedRows)
            h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
        else
            set(h.Handles.EDTtimeSheetStart,'String','');
            set(h.Handles.EDTtimeSheetEnd,'String','');
        end
    else
        % time vector is stored as a row
        if ~isempty(h.IOData.SelectedColumns)
            h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
        else
            set(h.Handles.EDTtimeSheetStart,'String','');
            set(h.Handles.EDTtimeSheetEnd,'String','');
        end
    end
end


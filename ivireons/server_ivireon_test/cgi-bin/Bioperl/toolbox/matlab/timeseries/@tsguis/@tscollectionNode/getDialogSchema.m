function Panel = getDialogSchema(this, manager)
%create the panel for tscollection object node

%   Author(s): Rajiv Singh
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.11.6.1 $ $Date: 2010/06/21 18:00:21 $

import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

%% Install listeners which update the tscollection table
this.addListeners([...
    handle.listener(this,'ObjectChildAdded',{@localChildAdded this}); ...
    handle.listener(this,'ObjectChildRemoved',{@localRemoveTsNode this}); ...
    handle.listener(this,'ObjectParentChanged',@(es,ed) delete(get(this,'TimeResetPanel')))]);

Lrename = handle.listener(this, this.findprop('Label'),'PropertyPostSet',...
    {@localTsCollNameChange});
Lrename.CallbackTarget = this;
this.addListeners(Lrename);

%% Show the panel
figure(double(manager.Figure));

%--------------------------------------------------------------------------
function Panel = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
import javax.swing.*;

%% Build tscollection panel
h.Handles.PNLTsOuter = uipanel('Parent',thisfig,'Units','Characters','Visible','off');
Panel = h.Handles.PNLTsOuter;
localConfigureMembersPanel(h);
localConfigureTimeInfoPanel(h);
localConfigurePlotPanel(h,manager);   

set(h.Handles.PNLTsOuter,'resizefcn',{@localPanelResize,h});
localPanelResize(h.Handles.PNLTsOuter,[],h);

%--------------------------------------------------
function localConfigureMembersPanel(h)

% Configure the contents of the "Manage Collection Members" panel

h.Handles.pnlMembers = uipanel('Parent',h.Handles.PNLTsOuter,'Units','Characters',...
    'Title',xlate('Manage collection members'),'tag','tsmembers','vis','on');

%% Add table
h.tscollectionMembersTable;

%% Add delete/add/extract push buttons
h.Handles.importBtn = uicontrol('parent',h.Handles.pnlMembers,'style','pushbutton','units','Characters',...
    'String','Add...','pos',[1 1 1 1]/10,'tag','importBtn','Callback',{@(es,ed) importTsCallback(h)});

%% Add remove button
h.Handles.removeBtn = uicontrol('parent',h.Handles.pnlMembers,'style','pushbutton','units','Characters',...
    'String','Remove','pos',[1 1 1 1]/10,'tag','removeBtn','Callback',{@(es,ed) removeTsCallback(h)});

%% Add extract timeseries button
h.Handles.extractBtn = uicontrol('parent',h.Handles.pnlMembers,'style','pushbutton','units','Characters',...
    'string','Extract','pos',[1 1 1 1]/10,'tag','extractBtn','Callback',{@localExtractTs h});

%% Resize function
set(h.Handles.pnlMembers,'resizefcn',{@localMembersResize h});

%--------------------------------------------------------------------------
function localConfigureTimeInfoPanel(h)
% Configure the contents of the "Edit Time Vecotr" panel
import javax.swing.*;

h.Handles.pnlTimeInfo = uipanel('Parent',h.Handles.PNLTsOuter,'Units','Characters',...
    'Title',xlate('Edit time vector'),'tag','timepanel_left');

%% Add time vector table
h.Handles.timeTable = tsdata.tscolltableadaptor;
h.Handles.timeTable.Timeseries = h.Tscollection;
h.Handles.timeTable.build;
h.Handles.PNLtimeTable = h.Handles.timeTable.addtopanel(h.Handles.pnlTimeInfo);
awtinvoke(h.Handles.timeTable.Table,'setAutoResizeMode(I)',JTable.AUTO_RESIZE_ALL_COLUMNS);

%% Size time table
set(h.Handles.PNLtimeTable,'Units','Characters',...
    'Parent',h.Handles.pnlTimeInfo);

%% Add current timeinfo text to the edit time panel
h.tscollectionCurrentTimeDisplay;
set(h.Handles.currentTimeInfo,'parent',h.Handles.pnlTimeInfo,'vis','on');

%% Add Delete Sample button
h.Handles.deleteBtn = uicontrol('parent',h.Handles.pnlTimeInfo,'style','pushbutton','units','Characters',...
    'string','Delete','tag','TimeRemoveBtn',...
    'callback',{@localDeleteTimeSamples,h});

%% Add new time vector button
h.Handles.newTimeBtn = uicontrol('parent',h.Handles.pnlTimeInfo,'style','pushbutton','units','Characters',...
    'string',xlate('Uniform Time Vector...'),'Callback',{@localShowTimeReset h});

%% Add "Insert time sample" button
h.Handles.addBtn = uicontrol('parent',h.Handles.pnlTimeInfo,'style','pushbutton','units','Characters',...
    'string','Insert','tag','TimeInsertBtn',...
    'callback',{@localInsertTimeSample,h});

%% Resize function
set(h.Handles.pnlTimeInfo,'resizefcn',{@localEditTimeResize h});
localEditTimeResize(h.Handles.pnlTimeInfo,[],h);

%--------------------------------------------------------------------------
function localConfigurePlotPanel(h,manager)

% Configure the contents of the plot panel
h.Handles.pnlPlot = uipanel('Parent',h.Handles.PNLTsOuter,'Units','Characters',...
    'Title',xlate('Plot collection members'),'tag','tsplot','vis','on');
h.NewPlotPanel = tsguis.newplotpanel;
h.NewPlotPanel.initialize(h.Handles.pnlPlot, manager, h, 'tscollection');
set(h.Handles.pnlPlot,'ResizeFcn',{@localPlotResize h.NewPlotPanel.Panel});

function localRemoveTsNode(es,ed,h)

if strcmp(ed.Type,'ObjectChildRemoved')
    h.updatePanel(ed.Child);
end

%--------------------------------------------------------------------------
function localExtractTs(es,ed,this)

% Extract the selected timeseries members to the parent Time Series node as
% a flat list.

selectedRows = this.Handles.membersTable.getSelectedRows+1;

for k = 1:length(selectedRows)
    selRow = selectedRows(k);
    if selRow>0
        tableData = cell(this.Handles.membersTable.getModel.getData);
        tsName = tableData{selRow,1};
        if isempty(tsName) %no members
            return
        end    
        ts = this.Tscollection.tsValue.getts(tsName);
        if ~isempty(ts)
            newname = sprintf('Copy_of_%s', ts.Name);
            k = 2;
            G = this.getParentNode.getChildren;
            for n = 1:length(G)
                if isa(G(n),'tsguis.tsnode') && strcmp(newname,G(n).Label)
                    newname = sprintf('Copy_%d_of_%s',k,ts.Name);
                    k = k+1;
                end
            end
            ts.Name = newname;
            childnode = ts.createTstoolNode(this.up);
            if ~isempty(childnode)
                childnode = this.up.addNode(childnode);
            end
        end
    end
end

%--------------------------------------------------------------------------
function localTsCollNameChange(es,ed,varargin)
% Update the Name text on the panel when the tscollectionNode name is
% changed. 

set(es.Handles.PNLTsOuter,'Title', ['Time Series Collection::',get(es,'Label')]);
es.up.updatePanel('child_rename'); %update the name in the table of the parent node.

%--------------------------------------------------------------------------
function localDeleteTimeSamples(es,ed,h)
% delete selected time samples from the tscollection time vector


hT = h.Handles.timeTable;
selrow = hT.Table.getSelectedRows;

if ~isempty(selrow)
    T = tsguis.transaction;
    T.ObjectsCell = {h.Tscollection};
    recorder = tsguis.recorder;

    % delete the selected samples from tscollection
    %h.Tscollection.delSample('index',selectedRows);
    delrow(hT);

    if strcmp(recorder.Recording,'on')
        T.addbuffer(sprintf('%%%% Delete selected samples from tscollection ''%s'':',...
            h.Tscollection.Name));
        T.addbuffer(sprintf('%s = delsamplefromcollection(%s,''index'',[%s])',...
            h.Tscollection.Name,h.Tscollection.Name, num2str(selrow(:)'+1)),...
            h.Tscollection);
    end

    %% Store transaction
    T.commit;
    recorder.pushundo(T);
end


%--------------------------------------------------------------------------
function localInsertTimeSample(es,ed,h)

h.Handles.timeTable.addrow;

%--------------------------------------------------------------------------
function localChildAdded(es,ed,this)

updatePanel(this);

ed.Child.HelpFile = 'ts_collection_member_cpanel';

function localEditTimeResize(es,ed,h)

pos = get(es,'Position');

set(h.Handles.currentTimeInfo,'Position',[1 5 pos(3)-4 2]);
set(h.Handles.PNLtimeTable,'Position',[2 8 pos(3)-4 pos(4)-10]);
set(h.Handles.addBtn,'Position',[pos(3)-13 3 10 1.5]);
set(h.Handles.deleteBtn,'Position',[pos(3)-24 3 10 1.5]);
set(h.Handles.newTimeBtn,'Position',[pos(3)-28 1 25 1.5]);

function localMembersResize(es,ed,h)

pos = get(es,'Position');

set(h.Handles.membersTableContainer,'Position',[2 3.5 pos(3)-5 pos(4)-5.4]);
set(h.Handles.extractBtn,'Position',[pos(3)-14 1 10 1.5]);
set(h.Handles.removeBtn,'Position',[pos(3)-25 1 10 1.5]);
set(h.Handles.importBtn,'Position',[pos(3)-36 1 10 1.5]);


function localPanelResize(es,ed,h)

pos = get(es,'Position');

set(h.Handles.pnlPlot,'Position',[1 1 pos(3)-3 7.5]);
set(h.Handles.pnlMembers,'Position',[1 8.5 pos(3)*.6-3 pos(4)-9]);
set(h.Handles.pnlTimeInfo,'Position',[pos(3)*.6-1 8.5 pos(3)*.4-1 pos(4)-9]);

function localPlotResize(es,ed,plotPanel)

pos = get(es,'Position');
set(plotPanel,'Position',[1 1 pos(3)-2 pos(4)-2]);

function localShowTimeReset(es,ed,h)

import com.mathworks.toolbox.timeseries.*;

tsguis.tsUniformTimeDlg(h,'open')

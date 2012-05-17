function Panel = getDialogSchema(this, manager)

%   Author(s): James Owen, Rajiv Singh
%   Copyright 2004-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.8 $ $Date: 2009/08/14 04:01:53 $


import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

%% Install listeners which update the timeseries table
this.addListeners([ ...
    handle.listener(this,'ObjectChildAdded',@(es,ed) updatePanel(this)); ...
    handle.listener(this,'ObjectChildRemoved',{@localRemoveTsNode this})]);

set(this.Handles.PNLTs,'Visible','on')

%--------------------------------------------------------------------------
function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
import javax.swing.*;

%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','Visible','off'); 

%% Build child timeseries panel
h.Handles.PNLTs = uipanel('Parent',f,'Units','Characters','Title',...
    xlate('Time Series'),'Visible','off');

%header info
h.tstable
set(h.Handles.PNLtsTable,'Units','Normalized','Parent',h.Handles.PNLTs,'Position',[.03 .1 .94 .88]);
BTNremove = uicontrol('Style','Pushbutton','String',xlate('Remove'),'Parent',h.Handles.PNLTs,...
    'Units','Characters','Callback',{@localRemoveTs h},'Position',[3 1 12 1.5]);

%% Assign and call the panel resize fcn
set(f,'ResizeFcn',{@localFigResize h.Handles.PNLTs})
localFigResize(f,[],h.Handles.PNLTs)

%--------------------------------------------------------------------------
function localSetVisible(es,ed,h)

children = h.find('-depth',inf,'-isa','uicontainer');
if ~isempty(children)
    set(children,'Visible',get(h,'Visible'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resize function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PNLTsResize(es,ed,PNLtsTable,BTNremove)

%% Time series panel resize callback. Puts the add and remove time series
%% buttons on the lower right and the table takes up the remaining space
%% between the upper text panel and the buttons.


%% Get component sizes
pos = get(es,'Position');
btnSize = 1.2*get(BTNremove,'Extent');
wT = 10;
margin = 1;
x0 = 0;
vm = btnSize(4)+0.5;

set(BTNremove,'Position',[max(1,pos(3)-btnSize(3)*0.7) margin btnSize(3)*0.6 btnSize(4)])

Pn = [margin,2*btnSize(4)+vm,max(1,pos(3)-2*margin),...
    0.99*max(1,pos(4)-3*margin-btnSize(4)-vm)]; 
Pn = hgconvertunits(ancestor(es,'figure'),Pn,get(es,'Units'),'pixels',es);
set(PNLtsTable,'Position', Pn);

%--------------------------------------------------------------------------
function localRemoveTsNode(es,ed,h)

if strcmp(ed.Type,'ObjectChildRemoved')
    h.updatePanel(ed.Child);
end

%--------------------------------------------------------------------------
function localRemoveTs(es,ed,this)

%% Remove ts callback

selectedRows = this.Handles.tsTable.getSelectedRows+1;
tsNodes = {};
for k = 1:length(selectedRows)
    selRow = selectedRows(k);
    if selRow>0
        tableData = cell(this.Handles.tsTable.getModel.getData);
        tsName = tableData{selRow,1};
        tsNodes{end+1} = this.getChildren('Label',tsName);
    end
end

for k = 1:length(tsNodes)
    tsNode = tsNodes{k};
    if ~isempty(tsNode)
        this.removeNode(tsNode); % Listeners will update the table
        % Must call drawnow here to prevent test failures due to events
        % order processing issues when deleting multiple rows (g564814)
        drawnow
    end
end

%clear selection
awtinvoke(this.Handles.tsTable,'clearSelection');
%--------------------------------------------------------------------------
function localFigResize(es,ed,PNLts)

%% Resize callback for tsparentnode panel

%% No-op if the panel is inivible or if there is no eventData passed with
%% the firing resize event
if strcmp(get(es,'Visible'),'off') && isempty(ed)
    return
end

%% Components and panels are repositioned relative to the main panel
mainpnlpos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Characters',get(es,'Parent'));

%% Set the tstable panel to take up all the space above the import panel
set(PNLts,'Position',[2 1.4 max(1,mainpnlpos(3)-4) max(1,mainpnlpos(4)-2.4)]);



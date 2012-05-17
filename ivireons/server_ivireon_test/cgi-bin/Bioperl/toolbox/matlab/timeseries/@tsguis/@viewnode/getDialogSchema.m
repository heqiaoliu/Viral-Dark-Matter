function Panel = getDialogSchema(this, manager)

% Copyright 2004-2005 The MathWorks, Inc.

import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

%% Listener to keep the time series table synched with the view
this.addListeners(handle.listener(this,'tschanged', @(es,ed) tstable(this)));

%% Show the panel
set(this.Handles.PNLTs,'Visible','on')
figure(double(manager.Figure))

function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','Visible','off');

%% Build time series panel
h.Handles.PNLTs = uipanel('Parent',f,'Units','Pixels','Title', ...
    xlate('Define Displayed Time Series'),'Visible','off');
h.tstable;
h.Handles.BTNremoveTs = uicontrol('Style','pushbutton','Parent', ...
    h.Handles.PNLTs,'Units','Pixels','String',xlate('Remove Time Series From View'),...
    'Callback',{@localRmTimeseries h manager});
h.Handles.BTNEditView = uicontrol('Style','pushbutton','Parent', ...
    h.Handles.PNLTs,'Units','Pixels','String',xlate('Edit Plot...'),...
    'Callback',{@localEditView h});
set(h.Handles.PNLTs,'ResizeFcn',{@PNLTsResize ...
    h.Handles.BTNremoveTs h.Handles.BTNEditView h.Handles.PNLTsTable})
PNLTsResize(h.Handles.PNLTs,[],h.Handles.BTNremoveTs,h.Handles.BTNEditView,...
    h.Handles.PNLTsTable);

%% Resize behavior
set(f,'ResizeFcn',{@localFigResize h.Handles.PNLTs});

function localSetVisible(es,ed,h)

children = h.find('-depth',inf);
for k=1:length(children)
    if isa(children(k),'uicontainer')
       set(children(k),'Visible',get(h,'Visible'));
    end
end
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resize functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function PNLTsResize(es,ed,BTNremoveTs,BTNEditView,PNLTsTable)

%% Resize fcn for the time series pane;

%% Get sizes and margins
pos = get(es,'Position');
margin = 10;

%% Set positions
btnSize = get(BTNremoveTs,'Extent');
rmBtnSize = [max(1,pos(3)-btnSize(3)-margin-18) margin btnSize(3)+18 btnSize(4)];
set(BTNremoveTs,'Position',rmBtnSize)
btnSize = get(BTNEditView,'Extent');
set(BTNEditView,'Position',[max(1,rmBtnSize(1)-margin-btnSize(3)-18) margin btnSize(3)+18 btnSize(4)])
set(PNLTsTable,'Position', ...
    [margin btnSize(4)+2*margin max(1,pos(3)-2*margin) ...
         max(1,pos(4)-(btnSize(4)+2*margin)-2*margin)])


function PNLAxesResize(es,ed,PNLaxesTable,BTNup,BTNdwn)

%% Resize fcn for axes panel
pos = get(es,'Position');
margin = 10;

%% Set positions
btnAddSize = get(BTNup,'Extent');
btnRemoveSize = get(BTNdwn,'Extent');
set(PNLaxesTable,'Position',[margin,2*margin+btnAddSize(4),max(1,pos(3)-2*margin),...
    max(1,pos(4)-4*margin-btnAddSize(4))])
set(BTNup, 'Position', [max(1,pos(3)-2*margin-btnAddSize(3)-btnRemoveSize(3)) margin ...
    btnAddSize(3:4)]);
set(BTNdwn, 'Position', [max(1,pos(3)-margin-btnRemoveSize(3)) margin ...
    btnRemoveSize(3:4)]);


function localFigResize(es,ed,PNLTs)

%% Resize callback for view panel

%% No-op if the panel is inivible or if there is no eventData passed with
%% the firing resize event
if strcmp(get(es,'Visible'),'off') && isempty(ed)
    return
end

gap = 3; % Interpanel gap
timePanelHeight = 141;
fixedVsize = 10+22+timePanelHeight+10+3*gap;

%% Components and panels are repositioned relative to the main panel
mainpnlpos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Pixels',get(es,'Parent'));

%% Set the time series panel to take up all the space horizonatally
%% and 1/3 of the available vertical space
PNLTsVsize = (max(1,mainpnlpos(4)-fixedVsize))/3;
pnlpos = hgconvertunits(ancestor(PNLTs,'figure'),...
    [10 10 max(1,mainpnlpos(3)-20) max(1,mainpnlpos(4)-20)],'Pixels',...
    get(PNLTs,'Units'),get(PNLTs,'Parent'));
set(PNLTs,'Position',pnlpos);

function localRmTimeseries(eventSrc,eventData,h,manager)

%% Remove time series button callback
selectedRow = h.Handle.tsTable.getSelectedRow+1;
if selectedRow>0
    h.removets(h.Plot.waves(selectedRow));
end

function localEditView(eventSrc,eventData,this)

%% Edit view button callback which detaches Opens the PlotTool 
%% Property Editor
if ~isempty(this.Plot) && ishandle(this.Plot)
    propedit(this.Plot.AxesGrid.Parent);
else
    errordlg('Plot is empty. Drag and drop a time series into the plot window before editing the plot.',...
        'Time Series Tools','modal')
end



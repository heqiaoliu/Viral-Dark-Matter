function Panel = getDialogSchema(this, manager)

% Copyright 2004-2005 The MathWorks, Inc.

import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

%% Show the panel
figure(double(manager.Figure))

% Temporary listeners to update table visibility when the enclosing panel
% visibility is modified
p = handle(Panel);
this.addListeners(handle.listener(p,p.findprop('Visible'),'PropertyPostSet',...
    {@localSetVisible p}));


function f = localBuildPanel(thisfig,h,manager)
%% Create and position the components on the panel
 
%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','Visible','off');

%% Build time series panel
h.Handles.PNLTs = uipanel('Parent',f,'Units','Characters','Title', ...
    xlate('Define Displayed Time Series'),'Visible','off');
h.Handles.BTNEditView = uicontrol('Style','pushbutton','Parent', ...
    f,'Units','Characters','String','Edit Plot...',...
    'Callback',{@localEditView h});
h.tspanel;

%% Resize behavior
set(f,'ResizeFcn',{@localFigResize h.Handles.PNLTs  h.Handles.BTNEditView});


function localSetVisible(es,ed,h)

children = h.find('-depth',inf,'-isa','uicontainer');
if ~isempty(children)
   set(children,'Visible',get(h,'Visible'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resize functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

function localFigResize(es,ed,PNLTs,EDITBTN)

%% Resize callback for view panel

%% No-op if the panel is inivible or if there is no eventData passed with
%% the firing resize event
if strcmp(get(es,'Visible'),'off') && isempty(ed)
    return
end

margin = 2;

% If userdata is not empty this is just a unit change issued by
% tsgetposition or tssetposition - no op
if ~isempty(get(es,'Userdata'))
    return
end

%% Components and panels are repositioned relative to the main panel
pos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'characters',get(es,'Parent'));

%% Set the time series panel to take up all the space horizonatally
%% the top 50 characters the available vertical space
set(PNLTs,'Position',[margin max(1,pos(4)-34) max(1,pos(3)-2*margin) 33])
btnSize = get(EDITBTN,'Extent');
BtnSize = [max(1,pos(3)-18) max(1,pos(4)-36) 15 1.5];
set(EDITBTN,'Position',BtnSize);


function localEditView(eventSrc,eventData,this)
%% Edit view button callback which detaches Opens the PlotTool 

%% Property Editor
if ~isempty(this.Plot) && ishandle(this.Plot) 
    propedit(this.Plot.AxesGrid.Parent);
else
    errordlg('Plot is empty. Drag and drop a time series into the plot window before editing the plot.',...
        'Time Series Tools','modal')
end



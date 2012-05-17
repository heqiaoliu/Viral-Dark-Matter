function initialize(h,f,manager,node,TypePlot)
% viewtypenames is an optional input; if undefined, the children of
% ViewNode are queried to build a list of all plot types.

%   Author(s): James Owen
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2009/12/14 22:25:54 $

%% newplotpanel constructor.

%% Set the parent to node associated with the parent panel
h.Node  = node;

%% Create the main panel
h.Panel = uibuttongroup('Parent',f,'Units','Characters',...
    'Title',xlate('Plot time series'),'ResizeFcn',{@localPnlResize h});

%% Create the components
h.Handles.RADIOnew = uicontrol('Style','radiobutton','Parent',h.Panel,'Units', ...
    'Characters','Position',[1.8 3.1529 37 1],'String',xlate('Create new  '),...
    'Value',true);
LBLType = uicontrol('Style','Text','Parent',h.Panel,'Units', ...
    'Characters','Position',[22 3.1529 10 1],'String',xlate('Type:'),...
    'HorizontalAlignment','Right');
if nargin<5 %viewtypenames is a default list of all types
    viewtypenames = get(manager.Root.TsViewer.ViewsNode.getChildren,{'Label'});
    TypePlot = 'timeseries';
elseif strcmpi(TypePlot,'tscollection') %only some plot types are available
    viewtypenames = {xlate('Time Plots');xlate('Spectral Plots');xlate('Histograms')};
    set(h.Panel,'title','','BorderType','none');
end
h.Handles.COMBViewType = uicontrol('Style','Popupmenu','String', ...
    viewtypenames,'Value',find(strcmp(xlate('Time Plots'),viewtypenames)),'Parent',...
    h.Panel,'Units','Characters','Callback',@(es,ed) set(h.Handles.RADIOnew,'Value',1));
if ~ismac
    set(h.Handles.COMBViewType,'BackgroundColor',[1 1 1]);
end
h.Handles.LBLviewName = uicontrol('Style','Text','String',xlate('Name:'),'Units','Characters',...
    'Parent',h.Panel,'HorizontalAlignment','Right');

h.Handles.EDITnewview = uicontrol('Style','edit','Parent',h.Panel,'Units',...
    'Characters','String','View1', ...
    'HorizontalAlignment','left','BackgroundColor',[1 1 1],...
    'Callback',@(es,ed) set(h.Handles.RADIOnew,'Value',1));
h.Handles.RADIOexist = uicontrol('Style','radiobutton','Parent',h.Panel,'Units', ...
    'Characters','Position',[1.8 1.15 25 1],'String',xlate('Add to existing plot'));
h.Handles.COMBexistview = uicontrol('Style','popup','Parent',h.Panel,'Units', ...
    'Characters','String',{'test'},'Callback',@(es,ed) set(h.Handles.RADIOexist,'Value',1));
if ~ismac
    set(h.Handles.COMBexistview,'BackgroundColor',[1 1 1]);
end
h.Handles.BTNdisp = uicontrol('Style','pushbutton','Parent',h.Panel,'Units', ...
    'Characters','String',xlate('Display'),'callback',@(es,ed) plot(h,manager), 'Tag', 'BTNdisp');

localPnlResize(h.Panel,[],h)
h.update(manager,[]);
%-------------------------------------------------------------------------
function localPnlResize(es,ed,h)

panelPos = get(es,'Position');
if panelPos(3)<8, return, end

blockWidth = max(panelPos(3)-51.2,10);
set(h.Handles.COMBViewType,'Position',[33 2.922 (blockWidth-13)/2 1.6149])
set(h.Handles.LBLviewName,'Position',[33+(blockWidth-13)/2+1 2.6915 11 1.6149])
set(h.Handles.EDITnewview,'Position',[33+(blockWidth-13)/2+13 2.9222 (blockWidth-13)/2 1.6149])
set(h.Handles.COMBexistview,'Position',[33 0.769 blockWidth 1.6918])
set(h.Handles.BTNdisp,'Position',[panelPos(3)-15 1 12.4 1.5380])

function print(this,Device)
%PRINT  Print LTI Viewer

%   Author: Kamesh Subbarao
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.12.4.10 $  $Date: 2009/03/09 19:07:08 $

printsetup(this,{'Visible'},{'off'});
layout(this);
switch Device
case 'printer'
   localPrintToPaper(this);
 case 'figure'
   localPrintToFigure(this);
end
printsetup(this,{'Visible'},{'on'});
layout(this);

%%%%%%%%%%%%%%%%%%%%%
% localPrintToPaper %
%%%%%%%%%%%%%%%%%%%%%
function localPrintToPaper(this)
%---Print to paper

% if paperposition mode is manual create hidden figure to print from 
% to prevent viewer from resizing to actual print size during printing
if strcmpi(get(this.Figure,'PaperPositionMode'),'manual')
    PrintProperties=struct(...,
        'PaperType', get(this.Figure,'PaperType'),...
        'PaperUnits', get(this.Figure,'PaperUnits'), ...
        'PaperPosition', get(this.Figure,'PaperPosition'), ...
        'PaperPositionMode', get(this.Figure,'PaperPositionMode'),...
        'PaperOrientation', get(this.Figure,'PaperOrientation'), ...
        'PrintTemplate',get(this.Figure,'PrintTemplate'),...
        'InvertHardcopy', get(this.Figure,'InvertHardcopy'));
    tempfig = localPrintToFigure(this);
    set(tempfig,PrintProperties)
    printdlg(double(tempfig));
    delete(tempfig);
    figure(double(this.Figure))
else
    set(this.Figure,'PaperPositionMode','auto');
    printdlg(double(this.Figure));
end

%%%%%%%%%%%%%%%%%%%%%%
% localPrintToFigure %
%%%%%%%%%%%%%%%%%%%%%%
function newfig = localPrintToFigure(this)
%----Print to figure
%---New figure
printfig = figure('Visible','off','Name','LTI Viewer Responses','Units',get(this.Figure,'Units'));
%---Match figure size (but not necessarily location)
pp1 = get(this.Figure,'Position');
pp2 = get(printfig,'Position');
set(printfig,'Position',[pp2(1) pp2(2)-(pp1(4)-pp2(4)) pp1(3) pp1(4)]);
%---Copy visible view axes
CopyAx = []; BackAx = [];
for n=find(ishandle(this.Views))',
   CopyAx = [CopyAx ; findobj(getaxes(this.Views(n,1).AxesGrid),'flat','Visible','on')];
   BackAx = [BackAx ; get(this.Views(n,1).AxesGrid,'BackgroundAxes')];
end
% Determine if legends are on for each axes
naxes = length(CopyAx);
for ct = naxes:-1:1;
    leg = legend(double(CopyAx(ct)));
    if isempty(leg)
        legendon(ct) = struct('on',false,'pos',[]);
    else
        legendon(ct) = struct('on',true,'pos',get(leg,'position'));
    end
end
% ---- Get the labels
labels1 = [get([BackAx],{'XLabel','YLabel','Title'});...
        get([CopyAx],{'XLabel','YLabel','Title'})];
if ~iscell(labels1)
    labels1 = {labels1};
end
labels1 = reshape([labels1{:,:}],size(labels1));
%---- Get label properties
PropVal = get(labels1,{'Position','Visible','Color'});
%
%---- Copy background axes to the new figure
%
B = copyobj(BackAx,printfig);
h = copyobj(CopyAx,printfig);
%

% Re: Need to copy annotation property until copyobj issue for hggroup is fixed
% g394314
CopyAxHGGroups = findobj(CopyAx,'type','hggroup');
hHGGroups = findobj(h,'type','hggroup');
for ct = 1:length(CopyAxHGGroups)
       hCopyAxAnnotations = get(CopyAxHGGroups(ct),'Annotation'); 
       hhAnnotations = get(hHGGroups(ct),'Annotation');
       hhAnnotations.LegendInformation.IconDisplayStyle = hCopyAxAnnotations.LegendInformation.IconDisplayStyle; 
       % Remove custom plot tools behavior
       localRemovePlotToolsBehavior(hHGGroups(ct));
end

% Set legend state to that of original figure
for ct = 1:naxes;
    if legendon(ct).on
        leg = legend(h(ct),'show');
        set(leg,'position',legendon(ct).pos);
    end
end

%---- Get the axes object properties
labels2 = get([B;h],{'XLabel','YLabel','Title'});
if ~iscell(labels2)
    labels2 = {labels2};
end
labels2 = reshape([labels2{:,:}],size(labels2));
%---- Apply old properties.
set(labels2,{'Position','Visible','Color'},PropVal)
set(labels2,'Units','Normalized');
% Enable HitTest so labels are editable in plottools
set(labels2,'HandleVisibility','on','HitTest','on');
%---Turn off buttondownfcn, deletefcn, etc.
set([h(:);B(:)],'Units','Normalized');
kids = get(h,{'children'});
if iscell(kids)
    kids = cat(1,kids{:});
else
    kids = kids(:);
end
hggroupkids = get(hHGGroups,{'children'});
if iscell(hggroupkids)
    hggroupkids = cat(1,hggroupkids{:});
else
    hggroupkids = hggroupkids(:);
end

%---Clear all callbacks/uicontextmenus/tags/userdata associated with new copies
set([h(:);kids(:);hggroupkids(:)],'DeleteFcn','','ButtonDownFcn','','UIContextMenu',[],'UserData',[],'Tag','');
%
% Clear appdata
for cnt = 1:length(h)
    % Remove custom plot tools behavior
    localRemovePlotToolsBehavior(h(cnt));
  
    if isappdata(h(cnt),'WaveRespPlot')
         rmappdata(h(cnt),'MWBYPASS_grid');
         rmappdata(h(cnt),'MWBYPASS_title');
         rmappdata(h(cnt),'MWBYPASS_xlabel');
         rmappdata(h(cnt),'MWBYPASS_ylabel');
         rmappdata(h(cnt),'MWBYPASS_axis');
         rmappdata(h(cnt),'WaveRespPlot');
    end
end

% Clear datacursor behavior
for cnt = 1:length(hggroupkids)
    localRemoveDataCursorBehavior(hggroupkids(cnt));
end

if nargout == 0
    %---Enable visibility
    set(printfig,'Visible','on');
else
    newfig = handle(printfig);
end

function localRemovePlotToolsBehavior(obj)
%Remove custom plot tools behavior
bb = get(obj,'Behavior');
updatebehavior = false;

if isfield(bb,'plottools')
    bb = rmfield(bb,'plottools');
    updatebehavior = true;
end
if isfield(bb,'plotedit')
    bb = rmfield(bb,'plotedit');
    updatebehavior = true;
end

if updatebehavior
    set(obj,'Behavior',bb);
end


function localRemoveDataCursorBehavior(obj)
%Remove custom data cursor behavior
bb = get(obj,'Behavior');

if isfield(bb,'datacursor')
    bb = rmfield(bb,'datacursor');
    set(obj,'Behavior',bb);
end

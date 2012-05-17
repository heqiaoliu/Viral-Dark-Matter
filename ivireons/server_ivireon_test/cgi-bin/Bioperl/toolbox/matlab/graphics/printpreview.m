function varargout = printpreview(varargin)
%PRINTPREVIEW  Display preview of figure to be printed
%    PRINTPREVIEW(FIG) Display preview of FIG

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2010/02/01 03:13:49 $

% Generate a warning in -nodisplay and -noFigureWindows mode.
warnfiguredialog('printpreview');

ppv_debug=false;
if nargout==1,
  varargout{1}=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -nojvm uses deprecated code.
if ~usejava('swing')
        Dlg=ppreview(varargin{:});
        if nargout==1, varargout{1}=Dlg; end;
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%Get the fig whose preview is requested
if nargin==1
  fig = varargin{1};
  if isempty(fig) || ~ishghandle(fig) || ~isscalar(fig)
    error('MATLAB:printpreview:InvalidFigureHandle', 'Invalid Figure handle.');
  end
else
  fig = gcf;
end

% See if a print preview dialog is already up.
figPreview = getappdata(fig, 'PrintPreview');
if isempty(figPreview) || ~ishghandle(figPreview)

    % First, get the props
    props = ppgetprinttemplate(fig);
    % append font name list and default
    fontList = listfonts;
    defaultFontName = get(fig,'DefaultTextFontName');

    %Create a figure for preview
    figPreview = figure('Name',xlate('Print Preview'),...
                        'IntegerHandle','off',...
                        'Tag','TMWFigurePrintPreview',...
                        'HandleVisibility','off',...
                        'Interruptible','on',...
                        'Renderer','painters',...
                        'units','pixels',...                        
                        'DeleteFcn','',...
                        'MenuBar','none',...
                        'ToolBar','none',...
                        'WindowStyle','normal',...                        
                        'Resize','on',...
                        'Visible','off',...
                        'NumberTitle','off',...
                        'Interruptible','off');
      
    %Add a listener to original figure so that the preview window can be 
    %closed when the actual figure closes
%    if useOriginalHGPrinting()        
%        l = handle.listener(handle(fig),'ObjectBeingDestroyed', {@onFigClosing,figPreview});
%        l(end+1) = handle.listener(handle(figPreview),'ObjectBeingDestroyed', ...
%                                               {@onFigPreviewClosing,fig});
%        setappdata(figPreview, 'PeerFigureListener', l);
%    else
        addlistener(fig, 'ObjectBeingDestroyed', @(src, evt) onFigClosing(src, evt, figPreview));
		addlistener(figPreview, 'ObjectBeingDestroyed', @(src, evt) onFigPreviewClosing(src, evt, figPreview));
        %%%%%%%% TODO
        % There should be a second listener, but this isn't working
        % correctly.  If the figure closes, the preview should close, but
        % if the preview closes, the figure should remain.
%        addlistener(figPreview, 'ObjectBeingDestroyed', @(src, evt) onFigClosing(src, evt, fig));
%    end

    %Snap the properties panel to the left
    dir = [prefdir '/PrintSetup'];
    if ~exist(dir,'dir')
        mkdir(dir);
    end
    panel = awtcreate('com.mathworks.page.export.PrintExportPanel', 'Ljava/lang/String;', dir);
    
    javacomponent(panel, java.awt.BorderLayout.WEST, figPreview); 
    
    model = panel.getPrintExportSettings();                  
    setappdata(figPreview,'JavaModel',model);
    
    p = awtcreate('com.mathworks.page.export.PreviewTabLayout', '(Lcom.mathworks.page.export.PrintExportSettings;)', model);
    r = awtinvoke(panel, 'addTabbedPanel(Ljava/lang/String;Ljava/lang/String;Lcom/mathworks/mwswing/MJPanel;)', xlate('Layout'),'Layout', p);  %#ok
    %panel.addTabbedPanel(xlate('Layout'), com.mathworks.page.export.PreviewTabLayout(model));
    p = awtcreate('com.mathworks.page.export.PreviewTabLines', '(Lcom.mathworks.page.export.PrintExportSettings;[Ljava/lang/String;Ljava/lang/String;)', ...
           model, fontList, defaultFontName);   %'[Ljava/lang/String;' defaultFontName
    r = awtinvoke(panel, 'addTabbedPanel(Ljava/lang/String;Ljava/lang/String;Lcom/mathworks/mwswing/MJPanel;)', xlate('Lines/Text'),'Lines/Text', p);  %#ok
    %panel.addTabbedPanel(xlate('Lines/Text'), com.mathworks.page.export.PreviewTabLines(model,fontList,defaultFontName));
    p = awtcreate('com.mathworks.page.export.PreviewTabColor', '(Lcom.mathworks.page.export.PrintExportSettings;)', model);
    r = awtinvoke(panel, 'addTabbedPanel(Ljava/lang/String;Ljava/lang/String;Lcom/mathworks/mwswing/MJPanel;)', xlate('Color'),'Color', p);  %#ok
    %panel.addTabbedPanel(xlate('Color'), com.mathworks.page.export.PreviewTabColor(model));
    p = awtcreate('com.mathworks.page.export.PreviewTabMisc', '(Lcom.mathworks.page.export.PrintExportSettings;)', model);
    r = awtinvoke(panel, 'addTabbedPanel(Ljava/lang/String;Ljava/lang/String;Lcom/mathworks/mwswing/MJPanel;)', xlate('Advanced'),'Advanced', p);  %#ok
    %panel.addTabbedPanel(xlate('Advanced'), com.mathworks.page.export.PreviewTabMisc(model));
    panel.setActiveTab(0);    

    %Init the preview region
    axPreview = createPreviewRegion(handle(figPreview),fig);

    setappdata(axPreview, 'PrintProperties', props);
    setPrintProps(axPreview, fig);
    updateImage(axPreview, fig, true);

    % Initialize the model
    %%%TODO - remove casts.
    panel.initialize(double(fig), double(axPreview), fieldnames(props), struct2cell(props));

    %Setup the callback to the (Java) PrintExportPanel
    callback = handle(model.getCallback(), 'callbackProperties');
    set(callback, 'delayedCallback', @onJavaCallback);
    setappdata(figPreview,'JavaCallback',callback);
    setappdata(figPreview,'JavaPanel',panel);
    
    % Set windowbutton functions on the preview figure
    if useOriginalHGPrinting()        
        set(figPreview,'WindowButtonDownFcn',@wbdown,...
                   'WindowButtonUpFcn',{@wbup,fig,model},...
                   'WindowButtonMotionFcn',{@wbmotion,fig},...
                   'ResizeFcn',{@onResize, fig});
    %else
    %%%%%%% TODO - Add back window button/motion functions for new
    %%%%%%% printing.
    end
               
    %Set the position of the figure
    pos = str2num(com.mathworks.page.export.PrintExportSettings.getFigPos);  %#ok
    if isempty(pos)
      pos = get(figPreview, 'position');
      screen = get(0,'ScreenSize');
      pos(2) = screen(4)/8.0; 
      pos(4) = 3*screen(4)/4.0;
    end
    set(figPreview, 'position', pos);   

    setappdata(fig, 'PrintPreview', figPreview);

    % Set the figPreview to be visible
    set(figPreview, 'Visible', 'on');

    % create refresh timer
    if useOriginalHGPrinting()        
        tim = timer('TimerFcn',{@refreshTimer,axPreview,fig}, 'Period',.2,...
                'ExecutionMode','FixedRate');
        setappdata(figPreview,'Timer',tim);
        start(tim);
    % else
    %%%%%%% TODO - Add back timer for new printing.
    end
else
    set(figPreview, 'Visible', 'on');
end

if nargout==1,
  varargout{1}=figPreview;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onFigClosing(src, evt, figPreview) %#ok
if ishghandle(figPreview)
	delete(figPreview);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onFigPreviewClosing(src, evt, figPreview) %#ok
if ~ishghandle(figPreview)
	return;
end
if isappdata(figPreview, 'Timer')
	t = getappdata(figPreview, 'Timer');
	if ~isempty(t)
	    stop(t);
	    delete(t);
	end
end
delete(figPreview);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function onFigPreviewClosing(src, evt, fig) %#ok
%if ishghandle(fig) && isappdata(fig, 'PrintPreview')
%    rmappdata(fig, 'PrintPreview')
%end
%dsrc = double(src);
%tim = getappdata(dsrc,'Timer');
%if ~isempty(tim)
%    stop(tim);
%    delete(tim);
%end
%pos = num2str(get(src, 'Position'));
%com.mathworks.page.export.PrintExportSettings.setFigPos(pos);
%l1 = getappdata(dsrc,'PeerFigureListener');
%if ~isempty(l1) && all(ishghandle(l1))
%    delete(l1);
%end
%l1 = getappdata(dsrc,'JavaCallback');
%if ~isempty(l1) && all(ishghandle(l1))
%    delete(l1);
%end
%if isappdata(dsrc,'JavaModel');
%    rmappdata(dsrc,'JavaModel');
%end
%set(dsrc,'WindowButtonUpFcn','');
%%panel = getappdata(dsrc,'JavaPanel');
%%delete(panel);
%jpanelBtns = findobj(dsrc,'Tag','PanelPreviewButtons');
%if ~isempty(jpanelBtns), 
%    delete(getappdata(double(src),'Buttons'))
%    delete(jpanelBtns); 
%end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axPreview = createPreviewRegion(figPreview,fig)

col = get(fig, 'DefaultUicontrolBackgroundColor');
set(figPreview, 'Color', col);

jpanelBtns = awtcreate('com.mathworks.page.export.PreviewZoomPanel');           %changed for java safety
[jpanelBtns pnlButtons] = javacomponent(jpanelBtns, [], handle(figPreview));
set(pnlButtons,'Tag','PanelPreviewButtons');
setappdata(figPreview,'JavaButtons',jpanelBtns);

pnlPreviewAxes = uicontainer('Parent',figPreview,'Tag','PanelPreviewAxes',...
                  'units','pixels','BackgroundColor',col);

% The various axes (PreviewAxes, Rulers)
axPreview = axes('Parent',pnlPreviewAxes,'Box','on',...
                 'Units', 'pixels',...
                 'XLim', [0 1], 'YLim', [0 1],...
                 'XTick',[],'YTick',[],...
                 'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
                 'Layer','bottom',...
                 'NextPlot','add',...
                 'ButtonDownFcn','',...
                 'Tag','PreviewAxes', ...
                 'ALimMode','manual','CLimMode','manual');
axRulerHor = axes('Parent',figPreview,'HandleVisibility','off',...
                  'Box','on','Units', 'pixels','Layer','top',...
                  'XGrid','on','GridLineStyle','-',...
                  'XAxisLocation','top',...
                  'XLim', [0 1], 'YLim', [0 1],...
                  'YTick', [], 'Color','w','TickLength',[0 0], ...
                  'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
                  'NextPlot','add',...
                  'ButtonDownFcn','',...
                  'Tag','PreviewRulerHorizontal', ...
                  'ALimMode','manual','CLimMode','manual');
axRulerVer = axes('Parent',figPreview,'HandleVisibility','off',...
                  'Box','on','Units', 'pixels','Layer','top',...
                  'XLim', [0 1], 'YLim', [0 1],'YDir','reverse',...
                  'YGrid','on','GridLineStyle','-',...
                  'XTick',[],'Color','w','TickLength',[0 0],...
                  'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
                  'NextPlot','add',...
                  'ButtonDownFcn','',...
                  'Tag','PreviewRulerVertical', ...
                  'ALimMode','manual','CLimMode','manual');
dark = col*.9;  %#ok
makeMarker(axRulerVer,'Top',col,'top');
makeMarker(axRulerVer,'Bottom',col,'bottom');
makeMarker(axRulerVer,'MiddleVer',col,'top');
makeMarker(axRulerHor,'Right',col,'right');
makeMarker(axRulerHor,'Left',col,'left');
makeMarker(axRulerHor,'MiddleHor',col,'right');

setappdata(axPreview, 'RulerHorizontal', axRulerHor);
setappdata(axPreview, 'RulerVertical', axRulerVer);

% the overlay axes with repaint busy message
overlay = axes('Parent',pnlPreviewAxes,'Box','off','Visible','off',...
               'Position',[0 0 1 1],'XLim',[0 1],'YLim',[0 1]);
text(.3,.5,'Recomputing preview...','Units','normalized',...
     'HorizontalAlignment','left','VerticalAlignment','middle',...
     'Parent',overlay,'Visible','off','Tag','BusyMessage',...
     'Interpreter','none');
setappdata(figPreview,'Overlay',overlay)

% The image for the printed figure
image([0 1],[0 1],[],...
      'Parent',axPreview, 'Visible', 'on');         

% Imaginary line in the previewAxes representing the margin (that is being
% moved interactively)
line('Parent',axPreview,'Visible','off','HandleVisibility','off',...
     'LineStyle',':','Tag','PreviewMargin');

% scrollbars
panx = uicontrol('Parent',figPreview,'Style','slider', ...
                 'Tag','PreviewPanx', ...
                 'Value',0.5);
pany = uicontrol('Parent',figPreview,'Style','slider', ...
                 'Tag','PreviewPany', ...
                 'Value',0.5);

%Temporarily turn MATLAB:addlistener:invalidEventName warning off
[lastWarnMsg lastWarnId] = lastwarn;
oldIENWarn = warning('off', 'MATLAB:addlistener:invalidEventName');
if useOriginalHGPrinting()        
    addlistener(panx, 'ActionEvent', @(src, evt) onScroll(src, evt, axPreview, fig));
    addlistener(pany, 'ActionEvent', @(src, evt) onScroll(src, evt, axPreview, fig));
else
    addlistener(panx, 'ContinuousValueChange', @(src, evt) onScroll(src, evt, axPreview, fig));
    addlistener(pany, 'ContinuousValueChange', @(src, evt) onScroll(src, evt, axPreview, fig));
end
warning(oldIENWarn.state, 'MATLAB:addlistener:invalidEventName');
lastwarn(lastWarnMsg, lastWarnId);

% The text fields representing the header, and the date
text('Parent',axPreview,...
     'verticalalignment','top','horizontalalignment','left',...
     'Clipping','on','tag','PreviewHeader');
text('Parent',axPreview,...
     'verticalalignment','top','horizontalalignment','right',...
     'Clipping','on','tag','PreviewDate');
     
% The Print, refresh, close, zoom controls
btn = jpanelBtns.getPrintButton();
h1 = handle(btn,'callbackproperties');
set(h1,'ActionPerformedCallback',{@onPrint,fig});
btn = jpanelBtns.getRefreshButton();
h2 = handle(btn,'callbackproperties');
set(h2,'ActionPerformedCallback',{@onRefresh,axPreview,fig});
btn = jpanelBtns.getCloseButton();
h3 = handle(btn,'callbackproperties');
set(h3,'ActionPerformedCallback',{@onClose,figPreview});
btn = jpanelBtns.getZoomComboBox();
h4 = handle(btn,'callbackproperties');
set(h4,'ActionPerformedCallback',{@onPaperZoom,axPreview,fig});
btn = jpanelBtns.getHelpButton();
h5 = handle(btn,'callbackproperties');
set(h5,'ActionPerformedCallback',@onHelp);
setappdata(figPreview,'Buttons',[h1 h2 h3 h4 h5]);
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizeDialog(axPreview, fig)
figPreview = ancestor(axPreview, 'figure');
figPos = get(figPreview,'Position'); % in pixels
rulerWidth = 40; %pixels 
scrollWidth = 15;
btnHeight = 30;
border = 10;

% Set the positions of the various panels and the scrollbars
pnlPreview = findobj(figPreview,'tag','PanelPreviewAxes');
pnlButtons = findobj(figPreview,'tag','PanelPreviewButtons');
set(pnlButtons, 'Position', [1 figPos(4)-btnHeight figPos(3) btnHeight]);
panx = findobj(figPreview, 'type', 'uicontrol', 'tag', 'PreviewPanx');
pany = findobj(figPreview, 'type', 'uicontrol', 'tag', 'PreviewPany');
panpos = [1 1 figPos(3)-scrollWidth scrollWidth];
panpos(3:4) = max(panpos(3:4),[1 1]);
set(panx, 'Position', panpos);
panpos = [figPos(3)-scrollWidth scrollWidth scrollWidth figPos(4)-scrollWidth-btnHeight];
panpos(3:4) = max(panpos(3:4),[1 1]);
set(pany, 'Position', panpos);
pos = [1 scrollWidth ...
       figPos(3)-scrollWidth ...
       figPos(4)-scrollWidth-btnHeight];
pnlpos = [pos(1)+rulerWidth+border pos(2)+border ...
          pos(3)-rulerWidth-2*border pos(4)-rulerWidth-2*border];
pnlpos(3:4) = max(pnlpos(3:4), [1 1]);
set(pnlPreview,'Position',pnlpos);

% Resize the preview axis & the rulers
resizePreviewAxes(axPreview, fig);
% Resize the preview image
resizePreviewImage(axPreview, fig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizePreviewAxes(axPreview, fig)  %#ok
figPreview = ancestor(axPreview, 'figure');
pnlPreview = findobj(figPreview,'tag','PanelPreviewAxes');
pos = getpixelposition(pnlPreview);
rulerWidth = 40; %pixels
panx = findobj(figPreview, 'Type', 'uicontrol', 'Tag', 'PreviewPanx');
pany = findobj(figPreview, 'Type', 'uicontrol', 'Tag', 'PreviewPany');
props = getappdata(axPreview, 'PrintProperties');
paperSize = props.PaperSize;

%Fit to window scale
zoom = getappdata(axPreview, 'ZoomFactor');
if isempty(zoom) %Fit to window
  pixperinch = min(pos(3)/paperSize(1), pos(4)/paperSize(2));
else
  zoom = hgconvertunits(handle(figPreview),[0 0 1 zoom],props.PaperUnits,'inches',0);
  posInches = hgconvertunits(handle(figPreview),pos,'pixels','inches',figPreview);
  zoom = zoom(end);
  pixperinch = pos(3)/posInches(3) * zoom;    
end
setappdata(axPreview, 'PixelsPerInch', pixperinch);

% Get the left,bottom,width,height (poistion) of the axPreview
px = get(panx, 'Value');
py = get(pany, 'Value');
axwidth = pixperinch*paperSize(1);
axheight = pixperinch*paperSize(2);
axleft = 0.5*(pos(3)-axwidth);
axbottom = 0.5*(pos(4)-axheight);
if axleft<0, axleft = -px*(axwidth-pos(3)); end
if axbottom<0, axbottom = -py*(axheight-pos(4)); end

%Set the SliderStep correctly
percent = pos(3)/axwidth;
if percent<1, percent = 1/(1/percent-1); else percent = inf; end
set(panx, 'SliderStep', [0.01 percent]);
percent = pos(4)/axheight;
if percent<1, percent = 1/(1/percent-1); else percent = inf; end
set(pany, 'SliderStep', [0.01 percent]);

pnlPreview = get(axPreview,'Parent');
ppos = get(pnlPreview,'Position');

% Set the positions of the preview axis & the rulers correctly
set(axPreview, 'Position', [axleft axbottom axwidth axheight],...
    'XLim', [0 paperSize(1)], 'YLim', [0 paperSize(2)]);
axRulerVer = getappdata(axPreview, 'RulerVertical');
axRulerHor = getappdata(axPreview, 'RulerHorizontal');
verpos = [30, ppos(2)+axbottom, rulerWidth-30, axheight];
verlim = [0 paperSize(2)];
if axbottom < 0 || axheight > ppos(4)
    verlim(1) = (axbottom+axheight-ppos(4))/pixperinch;
    verlim(2) = verlim(1) + ppos(4)/pixperinch;
    verpos([2 4]) = ppos([2 4]);
end
horpos = [axleft+ppos(1), ppos(2)+ppos(4)+10, axwidth, rulerWidth-30];
horlim = [0 paperSize(1)];
if axleft < 0 || axwidth > ppos(3)
    horlim(1) = -axleft/pixperinch;
    horlim(2) = horlim(1) + ppos(3)/pixperinch;
    horpos([1 3]) = ppos([1 3]);
end

set(axRulerVer, 'Position', verpos,'YLim', verlim);
set(axRulerHor, 'Position', horpos,'XLim', horlim);

%Resize the rulers
drawMarginMarker(axPreview, findobj(axRulerVer, 'tag', 'Top'), ...
                 props.PaperPosition(2));
drawMarginMarker(axPreview, findobj(axRulerVer, 'tag', 'Bottom'), ...
                 props.PaperPosition(2)+props.PaperPosition(4));
drawMarginMarker(axPreview, findobj(axRulerVer, 'tag', 'MiddleVer'), ...
                 props.PaperPosition(2)+props.PaperPosition(4)/2);
drawMarginMarker(axPreview, findobj(axRulerHor, 'tag', 'Left'), ...
                 props.PaperPosition(1));
drawMarginMarker(axPreview, findobj(axRulerHor, 'tag', 'Right'), ...
                 props.PaperPosition(1)+props.PaperPosition(3));
drawMarginMarker(axPreview, findobj(axRulerHor, 'tag', 'MiddleHor'), ...
                 props.PaperPosition(1)+props.PaperPosition(3)/2);
             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showHeaderAndDate(axPreview, fig)             
headertext = findall(axPreview, 'type',' text', 'tag', 'PreviewHeader');
datetext = findall(axPreview, 'type',' text', 'tag', 'PreviewDate');
figPreview = ancestor(axPreview, 'figure');

hs = getappdata(fig, 'PrintHeaderHeaderSpec');
if ~isempty(hs)
    gap = hgconvertunits(handle(fig), [hs.margin 0 0 0], 'points', get(fig,'PaperUnits'), fig);
    pos = hgconvertunits(handle(figPreview), getpixelposition(axPreview), ...
            'pixels', get(fig,'PaperUnits'), figPreview);
    gap = gap(1);
    paperSize = get(fig, 'PaperSize');
    zoom = pos(3)/paperSize(1);
    fontsize = hs.fontsize*zoom;
    topLeft = [gap, paperSize(2)-gap];
    topRight = [paperSize(1)-gap, paperSize(2)-gap];
    set(headertext,'position', topLeft, ...
        'string', hs.string, 'fontname', hs.fontname, ...
        'fontunits', 'points', 'fontsize', fontsize, ...
        'fontangle', hs.fontangle, 'fontweight', hs.fontweight);
    datestring = '';
    if ~strcmp(hs.dateformat,'none')
      datestring = datestr(now,hs.dateformat,'local');
    end
    set(datetext, 'position', topRight, ...
        'string', datestring, 'fontname', hs.fontname, ...
        'fontunits', 'points', 'fontsize', fontsize, ...
        'fontangle', hs.fontangle, 'fontweight', hs.fontweight);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pos = getMarkerPos(axPreview, group)
pixperinch = getappdata(axPreview, 'PixelsPerInch');
d = 2/pixperinch;
tag = get(group,'Tag');
marker = findobj(group,'Tag','Mark');
switch tag
    case {'Top','Bottom','MiddleVer'}
        markData = get(marker,'YData');
        pos = markData(1) + d;
    case {'Left','Right','MiddleHor'}
        markData = get(marker,'XData');
        pos = markData(1) + d;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawMarginMarker(axPreview, group, pos)
pixperinch = getappdata(axPreview, 'PixelsPerInch');
d = 2/pixperinch;
tag = get(group,'Tag');
marker = findobj(group,'Tag','Mark');
outside = findobj(group,'Tag','Out');
hit = findobj(group,'Tag','HitRegion');
dh = 3*d;
switch tag
  case 'Top'
    set(marker,'XData',[0 1 1 0],'YData',[pos-d pos-d pos+d pos+d]);
    set(hit,'XData',[0 1 1 0],'YData',[pos-dh pos-dh pos+dh pos+dh]);
    set(outside,'XData',[0 1 1 0],'YData',[pos pos -10000 -10000]);
  case 'Bottom'
    set(marker,'XData',[0 1 1 0],'YData',[pos-d pos-d pos+d pos+d]);
    set(hit,'XData',[0 1 1 0],'YData',[pos-dh pos-dh pos+dh pos+dh]);
    set(outside,'XData',[0 1 1 0],'YData',[pos pos 10000 10000]);
  case 'MiddleVer'
    set(marker,'XData',[0 1 1 0],'YData',[pos-d pos-d pos+d pos+d]);
    set(hit,'XData',[0 1 1 0],'YData',[pos-dh pos-dh pos+dh pos+dh]);
    set(outside,'XData',[0 1 1 0],'YData',[pos pos pos pos]);
  case 'Left'
    set(marker,'XData',[pos-d pos-d pos+d pos+d],'YData',[0 1 1 0]);
    set(hit,'XData',[pos-dh pos-dh pos+dh pos+dh],'YData',[0 1 1 0]);
    set(outside,'XData',[pos pos -10000 -10000],'YData',[0 1 1 0]);
  case 'Right'
    set(marker,'XData',[pos-d pos-d pos+d pos+d],'YData',[0 1 1 0]);
    set(hit,'XData',[pos-dh pos-dh pos+dh pos+dh],'YData',[0 1 1 0]);
    set(outside,'XData',[pos pos 10000 10000],'YData',[0 1 1 0]);
  case 'MiddleHor'
    set(marker,'XData',[pos-d pos-d pos+d pos+d],'YData',[0 1 1 0]);
    set(hit,'XData',[pos-dh pos-dh pos+dh pos+dh],'YData',[0 1 1 0]);
    set(outside,'XData',[pos pos pos pos],'YData',[0 1 1 0]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizePreviewImage(axPreview, fig)  %#ok
zoom = getappdata(axPreview, 'ZoomFactor');
if isempty(zoom), zoom=1; else zoom = ceil(zoom); end
figPreview = ancestor(axPreview, 'figure');
props = getappdata(axPreview, 'PrintProperties');
pos = hgconvertunits(handle(figPreview), get(axPreview, 'Position'), ...
                         get(axPreview,'units'), props.PaperUnits, figPreview);              
scale = pos(3)/props.PaperSize(1);              
img = findobj(axPreview, 'type', 'image');

% Set the image's xdata, ydata
xdata = [props.PaperPosition(1),props.PaperPosition(1)+props.PaperPosition(3)];
ydata = [props.PaperPosition(2),props.PaperPosition(2)+props.PaperPosition(4)];
ylim = get(axPreview, 'YLim');
ydata = [ylim(2)-ydata(2) ylim(2)-ydata(1)];
set(img, 'XData', xdata, 'YData', ydata);

% Set the cdata on the image
cdata = getappdata(axPreview, 'CData');
cdata = subsamplemex(cdata,scale,zoom);
set(img, 'CData', cdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getCData(axPreview, fig)
zoom = getappdata(axPreview, 'ZoomFactor');
if isempty(zoom), zoom=1; else zoom = ceil(zoom); end
res = get(0,'ScreenPixelsPerInch')*zoom;
tic;
pj = printjob;
pj.DriverColor = defaultprtcolor;
pj.DriverClass = 'IM';
pj.Driver = '-dzbuffer';
pj.DriverColorSet = 0;
pj.DPI = ceil(res);
pj = printprepare(pj,fig);
pj = preparepointers(pj);
if useOriginalHGPrinting()        
  db = get(fig, 'DoubleBuffer');
  set(fig, 'DoubleBuffer', 'on');
end

DPISwitch = ['-r' num2str(ceil(res))];
if strcmpi(get(fig,'renderer'),'opengl')
   hcform = '-dopengl';
else
   hcform = '-dzbuffer';
end
cdata = flipdim(hardcopy(fig,hcform,DPISwitch),1);
if ~ishghandle(fig), return; end
if useOriginalHGPrinting()        
    set(fig, 'DoubleBuffer', db);
end
restorepointers(pj);
printrestore(pj,fig);
if ~ishghandle(fig), return; end
refresh(fig);
if ~ishghandle(fig), return; end
elapse = toc;
if ishghandle(axPreview)
    %Set the cdata as appdata in axPreview
    setappdata(axPreview, 'CData', cdata);
    setappdata(axPreview, 'ElapseTime',elapse)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setPrintProps(axPreview, fig)
props = getappdata(axPreview, 'PrintProperties');
if isempty(props), return; end

%Stick these print properties in the figure (for future)
setprinttemplate(fig, props);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateImage(axPreview, fig, updateOnlyImage)
if nargin < 3, updateOnlyImage = false; end
%Get the image capture
elapse = getappdata(axPreview,'ElapseTime');
img = findobj(axPreview, 'Type', 'image');
txt = findobj(get(axPreview,'Parent'), 'Tag', 'BusyMessage');
if ~isempty(elapse) && elapse > 1
    img = findobj(axPreview, 'Type', 'image');
    set(img,'Visible','off');
    set(txt,'Visible','on','String','Recomputing preview...');
end
haderror = false;
try
    getCData(axPreview, fig);
catch ex
    setappdata(axPreview, 'CData',zeros(10) );
    set(img,'Visible','off');
    set(txt,'Visible','on',...
            'String',sprintf('Error refreshing preview:\n%s',ex.getReport('basic')));
    haderror = true;
end
if ~haderror && isempty(getappdata(fig,'PreviewUpdateData'))
    set(img,'Visible','on');
    set(txt,'Visible','off');
end
if ~updateOnlyImage && ~isempty(axPreview) && ishghandle(axPreview)
    resizePreviewAxes(axPreview, fig);
    resizePreviewImage(axPreview, fig);
    showHeaderAndDate(axPreview, fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onResize(src, evt, fig) %#ok
figPreview = double(src);
axPreview = findobj(figPreview, 'type', 'axes', 'tag', 'PreviewAxes');
if ~isempty(axPreview) && isappdata(axPreview, 'CData')  
  resizeDialog(axPreview, fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onJavaCallback(src, evtdata) %#ok
action = evtdata(1);
data = evtdata(2);
switch(action)
    case 'PropertyChange'
        onPrintPropsChanged(data);    
    case 'GenMCode'
        onGenerateMCode(data);
    case 'ChangeHeaderFont'
        onChangeHeaderFont(data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onPrintPropsChanged(evtdata)
fig = evtdata.getFigureHandle();
axPreview = evtdata.getPreviewAxesHandle();

% Make sure that the preview window has not been closed before this
% delayedCallback is called
if ~ishghandle(axPreview) || ~ishghandle(fig), return; end

% Get the NVP of properties
keys = evtdata.getKeys();
vals = evtdata.getValues();

if isempty(keys) % Request from Java to get default properties
    set(fig, 'PrintTemplate', []);
    props = ppgetprinttemplate(fig);
    evtdata.initialize(fig, axPreview, fieldnames(props), struct2cell(props));    
    refreshGUI(axPreview,fig,props);
else
    nfields = length(keys);
    t = cell(2,nfields);
    t(1,:) = keys(1:nfields);
    t(2,:) = vals(1:nfields);
    props = struct(t{:});
    % remember data for the update timer
    figPreview = ancestor(axPreview,'figure');
    setappdata(figPreview,'PreviewUpdateData',props);
end

updateFigSize(axPreview, fig);

function refreshTimer(src,ev,axPreview,fig)  %#ok
if ~ishghandle(axPreview) || ~ishghandle(fig), return; end
figPreview = ancestor(axPreview,'figure');
props = getappdata(figPreview,'PreviewUpdateData');
if ~isempty(props)
    setappdata(figPreview,'PreviewUpdateData',[]);
    try
        refreshGUI(axPreview,fig,props);
    catch ex  %#ok
    end
end

function refreshGUI(axPreview,fig,props)
propsOld = getappdata(axPreview, 'PrintProperties');
setappdata(axPreview, 'PrintProperties', props);
setPrintProps(axPreview, fig);
if ~strcmp(propsOld.PaperOrientation, props.PaperOrientation)
    resizePreviewAxes(axPreview, fig);
end
if strcmp(props.StyleSheet, 'default')
  initprintexporttemplate(fig, 'print', props);
else
    drawnow;
    if ishghandle(axPreview) && ishghandle(fig)
        updateImage(axPreview, fig);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onGenerateMCode(evtdata) %#ok
% prog = codegen.codeprogram;
% routine = codegen.coderoutine;
% prog.addSubFunction(routine);
% routine.Name = 'setupprint';
% arg = codegen.codeargument('Name', 'fig', 'Value', fig, ...
%                  'Comment', 'The figure handle to setup for printing');
% routine.addText('pt.ABC = 23;');
% routine.addText('setprinttemplate(',arg,', pt);');
% str = prog.toMCode(options); %Need to dig up on options
% com.mathworks.mlservices.MLEditorServices.newDocument(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onChangeHeaderFont(evtdata)
fig = evtdata.getFigureHandle();
axPreview = evtdata.getPreviewAxesHandle();

% Make sure that the preview window has not been closed before this
% delayedCallback is called
if ~ishghandle(axPreview) || ~ishghandle(fig), return; end

% Get the NVP of properties
keys = evtdata.getKeys();
vals = evtdata.getValues();

nfields = length(keys);
t = cell(2,nfields);
t(1,:) = keys(1:nfields);
t(2,:) = vals(1:nfields);
props = struct(t{:});

if isfield(props, 'HeaderFontName')
  font.FontName = props.HeaderFontName; 
else
  font.FontName = get(0,'DefaultTextFontName');
end
font.FontUnits = 'points';
if isfield(props, 'HeaderFontSize')
  font.FontSize = props.HeaderFontSize;
else
  font.FontSize = 10;
end
if isfield(props, 'HeaderFontAngle')
  font.FontAngle = props.HeaderFontAngle;
else
  font.FontAngle = 'normal';
end
if isfield(props, 'HeaderFontWeight')
  font.FontWeight = props.HeaderFontWeight;
else
  font.FontWeight = 'normal';
end   
font = uisetfont(font);
if isstruct(font) %User did not Cancel
    props.HeaderFontName = font.FontName;
    props.HeaderFontSize = font.FontSize;    
    props.HeaderFontAngle = font.FontAngle;
    props.HeaderFontWeight = font.FontWeight;

    setappdata(axPreview, 'PrintProperties', props);
    setPrintProps(axPreview, fig);
    updateImage(axPreview, fig);
    evtdata.setHeaderFont(font.FontName, font.FontSize, ...
                          font.FontWeight, font.FontAngle);
    showHeaderAndDate(axPreview, fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wbdown(src, evt) %#ok
figPreview = src;
axPreview = findobj(figPreview, 'Type', 'axes', 'Tag', 'PreviewAxes');
obj = hittest(figPreview);

if strcmp(get(obj,'type'), 'patch') 
    obj = get(obj,'Parent');
    setappdata(axPreview, 'PreviewMoveObject', obj);
    setappdata(axPreview, 'ObjectMoved', false)
    onRulerMarginChanged(axPreview, obj);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wbup(src, evt, fig, javamodel) %#ok
figPreview = src;
axPreview = findobj(figPreview, 'type', 'axes', 'tag', 'PreviewAxes');
if isappdata(axPreview, 'PreviewMoveObject')
    rmappdata(axPreview, 'PreviewMoveObject');
    rmappdata(axPreview, 'ObjectMoved')
    ln = findall(axPreview, 'type', 'line', 'tag', 'PreviewMargin');
    set(ln, 'Visible', 'off');
    setPrintProps(axPreview, fig);
    updateImage(axPreview, fig);
    props = getappdata(axPreview, 'PrintProperties');
    javamodel.initialize(fig, axPreview, fieldnames(props), struct2cell(props));
end
% We won't catch a mouse motion event over java components, so double check 
% cursor that's set. 
setCursor(figPreview); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wbmotion(src, evt, fig) %#ok
figPreview = src;
axPreview = findobj(handle(figPreview), 'type', 'axes', 'tag', 'PreviewAxes');
if isappdata(double(axPreview), 'PreviewMoveObject')
    obj = getappdata(axPreview, 'PreviewMoveObject');
    onRulerMarginChanged(axPreview, obj);
    resizePreviewImage(axPreview, fig);
else
    setCursor(figPreview);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setCursor(figPreview) 
obj = hittest(figPreview); 
if strcmp(get(obj,'type'), 'patch') 
    set(figPreview, 'Pointer', getappdata(get(obj,'Parent'),'Pointer')); 
else 
    set(figPreview, 'Pointer', 'arrow'); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onRulerMarginChanged(axPreview, h)
figPreview = ancestor(axPreview, 'figure');
point = get(figPreview, 'CurrentPoint');
axPos = getpixelposition(axPreview,true);
xlim = get(axPreview, 'XLim');
ylim = get(axPreview, 'YLim');
x = (point(1)-axPos(1))*xlim(2)/axPos(3);
y = (point(2)-axPos(2))*ylim(2)/axPos(4);
y = ylim(2)-y;
props = getappdata(axPreview, 'PrintProperties');
ln = findall(axPreview, 'Type', 'line', 'Tag', 'PreviewMargin');

scale = axPos(3)/xlim(2);
d = 2/scale;
moving = getappdata(axPreview,'ObjectMoved');
ruler = ancestor(h,'axes');
ticks = get(ruler,'XTick');
if isempty(ticks)
    ticks = get(ruler,'YTick');
end
step = unitstepsize(props.PaperUnits,ticks);
switch get(h,'Tag')
  case 'Left'
    right = props.PaperPosition(1)+props.PaperPosition(3);    
    if abs(x-right) > 4*d, moving = true; end
    x = round(x/step)*step;
    % If x woulc be less than one step away from the middle, stop moving:
    h1 = findobj(get(h,'Parent'),'Tag','MiddleHor');
    xM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed x and the middle ruler is less
    % than one step, don't allow the move. Since the left marker should
    % always have a smaller X than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if xM - x < step
        moving = false;
    end
    if moving && x < xlim(2) && x > xlim(1)
        drawMarginMarker(axPreview, h, x);
        set(ln,'XData',[x x],'YData',ylim,'Visible','on');    
        props.PaperPosition(1) = x;
        props.PaperPosition(3) = right-x;
        % draw other markers
        drawMarginMarker(axPreview, h1, x+props.PaperPosition(3)/2);
    end
  case 'Right'
    if abs(x-props.PaperPosition(1)) > 4*d, moving = true; end
    x = round(x/step)*step;
    h1 = findobj(get(h,'Parent'),'Tag','MiddleHor');
    xM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed x and the middle ruler is less
    % than one step, don't allow the move. Since the right marker should
    % always have a larger X than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if x - xM < step
        moving = false;
    end
    if moving && x < xlim(2) && x > xlim(1)
        drawMarginMarker(axPreview, h, x);
        set(ln,'XData',[x x],'YData',ylim,'Visible','on');
        props.PaperPosition(3) = x-props.PaperPosition(1);
        % draw other markers
        drawMarginMarker(axPreview, h1, x-props.PaperPosition(3)/2);
    end
  case 'MiddleHor'
    half = props.PaperPosition(3)/2;
    mid = props.PaperPosition(1) + half;
    if abs(x-mid) > 4*d, moving = true; end
    x = round(x/step)*step;
    if moving && x < xlim(2) && x > xlim(1)
        drawMarginMarker(axPreview, h, x);
        set(ln,'XData',[x x],'YData',ylim,'Visible','on');
        props.PaperPosition(1) = x-props.PaperPosition(3)/2;
        % draw other markers
        h1 = findobj(get(h,'Parent'),'Tag','Left');
        drawMarginMarker(axPreview, h1, x - half);
        h2 = findobj(get(h,'Parent'),'Tag','Right');
        drawMarginMarker(axPreview, h2, x + half);
    end
  case 'Top'
    bottom = props.PaperPosition(2)+props.PaperPosition(4);
    if abs(y-bottom) > 4*d, moving = true; end
    y = round(y/step)*step;
    h1 = findobj(get(h,'Parent'),'Tag','MiddleVer');
    yM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed y and the middle ruler is less
    % than one step, don't allow the move. Since the top marker should
    % always have a smaller Y than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if yM - y < step
        moving = false;
    end    
    if moving && y < ylim(2) && y > ylim(1)
        drawMarginMarker(axPreview, h, y);
        set(ln,'XData',xlim,'YData',[ylim(2)-y ylim(2)-y],'Visible','on');    
        props.PaperPosition(2) = y;
        props.PaperPosition(4) = bottom-y;
        % draw other markers
        drawMarginMarker(axPreview, h1, y+props.PaperPosition(4)/2);
    end
  case 'Bottom'
    if abs(y-props.PaperPosition(2)) > 4*d, moving = true; end
    y = round(y/step)*step;
    h1 = findobj(get(h,'Parent'),'Tag','MiddleVer');
    yM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed y and the middle ruler is less
    % than one step, don't allow the move. Since the bottom marker should
    % always have a larger Y than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if y - yM < step
        moving = false;
    end   
    if moving && y < ylim(2) && y > ylim(1)
        drawMarginMarker(axPreview, h, y);
        set(ln,'XData',xlim,'YData',[ylim(2)-y ylim(2)-y],'Visible','on');
        props.PaperPosition(4) = y-props.PaperPosition(2);
        % draw other markers
        drawMarginMarker(axPreview, h1, y-props.PaperPosition(4)/2);
    end
  case 'MiddleVer'
    half = props.PaperPosition(4)/2;
    mid = props.PaperPosition(2) + half;
    if abs(y-mid) > 4*d, moving = true; end
    y = round(y/step)*step;
    if moving && y < ylim(2) && y > ylim(1)
        drawMarginMarker(axPreview, h, y);
        set(ln,'XData',xlim,'YData',[ylim(2)-y ylim(2)-y],'Visible','on');
        props.PaperPosition(2) = y-props.PaperPosition(4)/2;
        % draw other markers
        h1 = findobj(get(h,'Parent'),'Tag','Top');
        drawMarginMarker(axPreview, h1, y - half);
        h2 = findobj(get(h,'Parent'),'Tag','Bottom');
        drawMarginMarker(axPreview, h2, y + half);
    end
end
setappdata(axPreview,'ObjectMoved',moving);
setappdata(axPreview,'PrintProperties',props);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onPrint(src, evt, fig) %#ok
printdlg(fig);
%Bring the preview window toFront
figPreview = getappdata(fig, 'PrintPreview');
if ishghandle(figPreview)
    figure(figPreview);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onRefresh(src, evt, axPreview, fig) %#ok
updateImage(axPreview,fig);
updateFigSize(axPreview, fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateFigSize(axPreview, fig)
figPreview = ancestor(axPreview,'figure');
model = getappdata(figPreview,'JavaModel');
if ~isempty(model)
    figSize = hgconvertunits(handle(fig), get(fig, 'Position'), ...
        get(fig, 'units'), char(getUnits(model)), 0);
    javaFigSize = model.getFigSize;
    % If the figure size has changed since the last refresh, update it in
    % the java model.
    if ~isequal(javaFigSize,[figSize(3);figSize(4)])
        awtinvoke(model,'setFigSize(Ljava.lang.Object;DD)',[],figSize(3),figSize(4));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onClose(src, evt, figPreview) %#ok
delete(figPreview);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onHelp(src, evt) %#ok
doc('printpreview');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onPaperZoom(src, evt, axPreview, fig) %#ok
comboZoom = get(evt, 'Source');
value = comboZoom.getSelectedItem();

if comboZoom.getSelectedIndex() == comboZoom.getItemCount()-1
    % last item is Overview as a localized string
    if isappdata(axPreview, 'ZoomFactor')
      rmappdata(axPreview, 'ZoomFactor');
      updateImage(axPreview, fig);
    end
else
    d = str2double(value);
    if ~isnan(d)
      setappdata(axPreview, 'ZoomFactor', d/100.0);
      updateImage(axPreview, fig);      
    else
      warndlg('This is not a valid measurement', xlate('PrintPreview warning'), 'modal');
      oldval = getappdata(axPreview, 'ZoomFactor');
      if isempty(oldval), oldval = 'Fit'; else oldval=num2str(oldval*100); end
      awtinvoke(comboZoom,'setSelectedItem(Ljava/lang/Object;)',oldval);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onScroll(src,evt,axPreview,fig) %#ok
resizePreviewAxes(axPreview, fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = makeMarker(parent,tag,color,pointer)
g = hgtransform('parent',parent,'Hittest','off','Tag',tag);
setappdata(g,'Pointer',pointer);

patch('Parent', g, 'Tag', 'Out','FaceColor',color,'Hittest','off');
patch('Parent', g, 'Tag', 'HitRegion','FaceColor','none','EdgeColor','none');
patch('Parent', g, 'Tag', 'Mark','Hittest','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pt = appendPropsFromFigToPrintTemplate(pt,h)

pt.StyleSheet = 'default';
% Get the default paper information from the appdata.
if isappdata(h,'PrintDefaultPaperInformation')
    ptInfo = getappdata(h,'PrintDefaultPaperInformation');
else
    % version 1 is R12 through R2006a, version 2 is after R2006b
    ptInfo.VersionNumber = 2;
    ptInfo.FontName = '';
    ptInfo.FontSize = 0;
    ptInfo.FontSizeType = 'screen';
    ptInfo.FontAngle = '';
    ptInfo.FontWeight = '';
    ptInfo.FontColor = '';
    ptInfo.LineWidth = 0;
    ptInfo.LineWidthType = 'screen';
    ptInfo.LineMinWidth = 0;
    ptInfo.LineStyle = '';
    ptInfo.LineColor = '';
    ptInfo.PrintActiveX = 0;
    ptInfo.GrayScale = 0;
    ptInfo.BkColor= 'white';
    ptInfo.DriverColor = defaultprtcolor;
    % get the papertype,size, orientation, etc. from the figure
    ptInfo.PaperType = get(h, 'PaperType');
    ptInfo.PaperSize = get(h, 'PaperSize');
    ptInfo.PaperOrientation = get(h, 'PaperOrientation');
    ptInfo.PaperUnits = get(h, 'PaperUnits');
    paperPosition = get(h, 'PaperPosition');
    ptInfo.PaperPosition = [paperPosition(1), ...
        ptInfo.PaperSize(2) - (paperPosition(2) + paperPosition(4)), ...
        paperPosition(3), ...
        paperPosition(4)];
    ptInfo.PaperPositionMode = get(h, 'PaperPositionMode');

    ptInfo.FigSize = hgconvertunits(handle(h), get(h, 'Position'), ...
        get(h, 'units'), ptInfo.PaperUnits, 0);
    
    ptInfo.FigSize = ptInfo.FigSize(3:4);
    ptInfo.InvertHardCopy = get(h, 'InvertHardCopy');
    setappdata(h,'PrintDefaultPaperInformation',ptInfo);
end
fNames = fieldnames(ptInfo);
for i = 1:numel(fNames)
    pt.(fNames{i}) = ptInfo.(fNames{i});
end

% get the figure header info...
if isappdata(h, 'PrintHeaderHeaderSpec')
    rmappdata(h, 'PrintHeaderHeaderSpec'); 
end
pt.HeaderText = '';
pt.HeaderDateFormat = 'none';


function props = ppgetprinttemplate(fig)
props = getprinttemplate(fig);
if isempty(props) || ~isequal(props.VersionNumber,2)
    if isempty(props)
        props = printtemplate;
    end
    props = appendPropsFromFigToPrintTemplate(props,fig);
end

function step = unitstepsize(units,ticks)
switch units
  case 'inches'
    scale = 1/8;
  otherwise
    scale = 1/10;
end
if length(ticks) < 2, ticks = [0 1]; end
step = (ticks(2)-ticks(1))*scale;

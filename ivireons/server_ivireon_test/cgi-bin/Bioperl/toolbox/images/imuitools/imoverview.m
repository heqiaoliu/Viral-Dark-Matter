function hout = imoverview(varargin)
%IMOVERVIEW Overview tool for image displayed in scroll panel.
%   IMOVERVIEW(HIMAGE) creates an Overview tool associated with the image
%   specified by the handle HIMAGE, called the target image. HIMAGE must be
%   contained in a scroll panel created by IMSCROLLPANEL.
%
%   The Overview tool is a navigation aid for images displayed in a scroll
%   panel. IMOVERVIEW creates the tool in a separate figure window that displays
%   the target image in its entirety, scaled to fit. Over this scaled version of
%   image, the tool draws a rectangle, called the detail rectangle, that shows
%   the portion of the target image that is currently visible in the scroll
%   panel.  To view portions of the image that are not currently visible in the
%   scroll panel, move the detail rectangle in the Overview tool.
%
%   FIG = IMOVERVIEW(...) returns a handle to the Overview tool figure.
%
%   Note
%   ----
%   To create an Overview tool that can be embedded in an existing figure or
%   uipanel object, use IMOVERVIEWPANEL.
%
%   Example
%   -------
%
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('tape.png');
%       hSP = imscrollpanel(hFig,hIm);
%       api = iptgetapi(hSP);
%       api.setMagnification(2) % 2X = 200%
%       imoverview(hIm)
%
%   See also IMOVERVIEWPANEL, IMSCROLLPANEL, IMTOOL.

%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.17 $  $Date: 2009/02/06 14:20:10 $

iptchecknargin(1, 1, nargin, mfilename);
himage = varargin{1};

iptcheckhandle(himage,{'image'},mfilename,'HIMAGE',1)
hScrollpanel = checkimscrollpanel(himage,mfilename,'HIMAGE');
apiScrollpanel = iptgetapi(hScrollpanel);

hScrollpanelFig = ancestor(hScrollpanel,'figure');
hScrollpanelIm  = himage;

hOverviewFig = figure('Menubar','none',...
    'IntegerHandle','off',...
    'HandleVisibility','Callback',...
    'NumberTitle','off',...
    'Name',createFigureName('Overview',hScrollpanelFig), ...
    'Tag','imoverview',...
    'Colormap',get(hScrollpanelFig,'Colormap'),...
    'Visible','off',...
    'DeleteFcn',@deleteOverviewFig);

suppressPlotTools(hOverviewFig);

% keep the figure name up to date
linkToolName(hOverviewFig,hScrollpanelFig,'Overview');

% set figure size
fig_pos = get(hOverviewFig,'Position');
set(hOverviewFig,'Position',[fig_pos(1:2) 200 200]);

% drawnow is a workaround to geck 268506
drawnow;

% use same renderer as parent
set(hOverviewFig,'Renderer',get(hScrollpanelFig,'Renderer'));

% create overview panel
imoverviewpanel(hOverviewFig,hScrollpanelIm);

% customize overview figure toolbar and menubar
toolbarOld = findall(hOverviewFig,'type','uitoolbar');
delete(toolbarOld);
[zoomInButton zoomOutButton] = createToolbar(hOverviewFig,apiScrollpanel);
createMenubar(hOverviewFig,apiScrollpanel);

% link colormap to target image figure's colormap
linkFig = linkprop([hScrollpanelFig hOverviewFig],'Colormap');
setappdata(hOverviewFig, 'OverviewListeners', linkFig);

% Position the overview figure to the upper left and make visible.
iptwindowalign(hScrollpanelFig, 'left', hOverviewFig, 'right');
iptwindowalign(hScrollpanelFig, 'top', hOverviewFig, 'top');
set(hOverviewFig,'Visible','on')

% Set up wiring so zoom buttons enable/disable according to
% magnification of main image.
updateZoomButtons(apiScrollpanel.getMagnification())
magCallbackID = apiScrollpanel.addNewMagnificationCallback(@updateZoomButtons);

% create listeners and register tool handle
reactToImageChangesInFig(himage,hOverviewFig,@reactDeleteFcn,...
    @reactRefreshFcn);
registerModularToolWithManager(hOverviewFig,himage);

if (nargout==1)
    hout = hOverviewFig;
end


    %------------------------------
    function updateZoomButtons(mag)
        
        if ishghandle(hOverviewFig)
            
            if mag <= apiScrollpanel.getMinMag();
                set(zoomOutButton,'Enable','off')
            else
                set(zoomOutButton,'Enable','on')
            end
            
            % arbitrary big choice, 1024 screen pixels for one image
            % pixel, same as in imtool.m
            if mag>=1024
                set(zoomInButton,'Enable','off')
            else
                set(zoomInButton,'Enable','on')
            end
        end
        
    end


    %-------------------------------
    function reactDeleteFcn(obj,evt) %#ok<INUSD>
        
        if ishghandle(hOverviewFig)
            delete(hOverviewFig);
        end
        
    end


    %-------------------------------
    function reactRefreshFcn(obj,evt) %#ok<INUSD>
        
        % close tool if the target image cdata is empty
        if isempty(get(himage,'CData'))
            reactDeleteFcn();
        end
        
    end


    %-----------------------------------
    function deleteOverviewFig(varargin)
        
        apiScrollpanel.removeNewMagnificationCallback(magCallbackID);
        
    end

end % imoverview


%---------------------------------------------------------------------------------
function [zoomInButton zoomOutButton] = createToolbar(hOverviewFig,apiScrollpanel)

toolbar =  uitoolbar(hOverviewFig);

[iconRoot,iconRootMATLAB] = ipticondir;

zoomInIcon = makeToolbarIconFromPNG(fullfile(iconRoot,...
    'overview_zoom_in.png'));
zoomInButton = createToolbarPushItem(toolbar,zoomInIcon,...
    {@zoomIn},...
    'Zoom in');

zoomOutIcon = makeToolbarIconFromPNG(fullfile(iconRoot,...
    'overview_zoom_out.png'));
zoomOutButton = createToolbarPushItem(toolbar,zoomOutIcon,...
    {@zoomOut},...
    'Zoom out');

if ~isdeployed
    helpIcon = makeToolbarIconFromGIF(fullfile(iconRootMATLAB, 'helpicon.gif'));
    createToolbarPushItem(toolbar,helpIcon,@showOverviewHelp,'Help');
end

    %------------------------
    function zoomIn(varargin)
        
        newMag = findZoomMag('in',apiScrollpanel.getMagnification());
        apiScrollpanel.setMagnification(newMag)
        
    end % zoomIn


    %-------------------------
    function zoomOut(varargin)
        
        newMag = findZoomMag('out',apiScrollpanel.getMagnification());
        apiScrollpanel.setMagnification(newMag)
        
    end %zoomOut


end % createToolbar


%--------------------------------------------------
function createMenubar(hOverviewFig,apiScrollpanel)

filemenu = uimenu(hOverviewFig, 'Label','&File','Tag','file menu');
editmenu = uimenu(hOverviewFig, 'Label','&Edit','Tag','edit menu');

if isJavaFigure
    uimenu(hOverviewFig, 'Label', '&Window','tag','window menu', ...
        'Callback', winmenu('callback'));
end

% File menu
uimenu(filemenu,'Label','&Print To Figure',...
    'Tag','print to figure menu item',...
    'Callback',@(varargin) printImageToFigure(hOverviewFig));

uimenu(filemenu,'Label','&Close','Accelerator','W',...
    'Tag','close menu item',...
    'Callback',@(varargin) close(hOverviewFig));

% Edit menu
uimenu(editmenu, 'Label', '&Copy Position', ...
    'Callback', @(varargin) clipboard('copy', apiScrollpanel.getVisibleImageRect()), ...
    'Tag', 'copy position menu item');


% Help menu
if ~isdeployed
    helpmenu = uimenu(hOverviewFig, 'Label','&Help','Tag','help menu');
    uimenu(helpmenu,'Label','&Overview Help','Tag',...
        'help menu item','Callback',@showOverviewHelp);
    
    iptstandardhelp(helpmenu);
end

end % createMenubar


%-------------------------------------------------------------------
function item = createToolbarPushItem(toolbar,icon,callback,tooltip)

item = uipushtool(toolbar,...
    'Cdata',icon,...
    'TooltipString',tooltip,...
    'Tag',[lower(tooltip) ' toolbar button'],...
    'ClickedCallback',callback);

end % createToolbarPushItem


%---------------------------------
function showOverviewHelp(obj,evt) %#ok<INUSD>

topic = 'overview_tool_help';
helpview([docroot '/toolbox/images/images.map'],topic);

end % showOverviewHelp


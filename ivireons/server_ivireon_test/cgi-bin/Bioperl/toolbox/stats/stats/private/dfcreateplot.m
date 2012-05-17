function dffig = dfcreateplot
%DFCREATEPLOT Create plot window for DFITTOOL

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:43 $
%   Copyright 2003-2008 The MathWorks, Inc.

% Get some screen and figure position measurements
tempFigure=figure('visible','off','units','pixels',...
                  'Tag','Distribution Fitting Figure');
dfp=get(tempFigure,'position');
dfop=get(tempFigure,'outerposition');
diffp = dfop - dfp;
xmargin = diffp(3);
ymargin = diffp(4);
close(tempFigure)
oldu = get(0,'units');
set(0,'units','pixels');
screenSize=get(0,'screensize');
screenWidth=screenSize(3); 
screenHeight=screenSize(4);
set(0,'units',oldu');

% Get the desired width and height
width=dfp(3)*1.2 + xmargin;
height=dfp(4)*1.2 + ymargin;
if width > screenWidth
  width = screenWidth-10-xmargin;
end
if height > screenHeight;
  height = screenHeight-10-ymargin;
end

% Calculate the position on the screen
leftEdge=min((screenWidth/3)+10+xmargin/2, screenWidth-width-10-2*xmargin);
bottomEdge=(screenHeight-height)/2;

% Make an invisible figure to start
dffig=figure('Visible','off','IntegerHandle','off',...
             'HandleVisibility','callback',...
             'color',get(0,'defaultuicontrolbackgroundcolor'),...
             'name','Distribution Fitting Tool',...
             'numbertitle','off',...
             'units','pixels',...
             'position',[leftEdge bottomEdge width height], ...
             'CloseRequestFcn',@closefig, ...
             'DeleteFcn',@deletefig, ...
             'PaperPositionMode','auto',...
             'WindowStyle', 'Normal', ...
             'DockControls', 'off' );

dfgetset('dffig',dffig);

% Set default print options
pt = printtemplate;
pt.PrintUI = 0;
set(dffig,'PrintTemplate',pt)

% Add buttons along the top
dfaddbuttons(dffig);

% We want a subset of the usual toolbar
% Instead of calling adjusttoolbar, there is a handlegraphics bug
% that turned the toolbar off when the buttons were created, so
% we have to toggle it back on.
dftoggletoolbar(dffig,'on');

% We want a subset of the usual menus and some more toolbar icons
dfadjustmenu(dffig);

% Set up axes the way we want them
ax=axes('Parent',dffig, 'box','on','Tag','main',...
        'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
        'CLimMode','manual','AlimMode','manual');

% Adjust layout of buttons and graph
if ~ispc    % some unix platforms seem to require this
   set(dffig,'Visible','on');
   drawnow;
end
dfadjustlayout(dffig);

% Remember current position
dfgetset('oldposition',get(dffig,'Position'));
dfgetset('oldunits',get(dffig,'Units'));

% Now make the figure visible
if ispc
   set(dffig,'visible','on');
end
set(dffig, 'ResizeFcn','dfittool(''adjustlayout'')');
drawnow;

% Create context menus for data and fit lines
dfdocontext('create', dffig);

% Update curves to cover current x limits
addlistener(ax, 'XLim', 'PostSet', @(src,evt) localupdatecurves(ax));


% ---------------------- function to react to axis limit changes
function localupdatecurves(ax)
xlim = get(ax,'xlim');
fitdb = getfitdb;
ft = down(fitdb);
while(~isempty(ft))                    % loop over all fits
    fitxlim = get(ft,'xlim');
    if isempty(fitxlim)
        % fit has no x limits yet, so update it
        doit = true;
        newlim = xlim;
    else
        xrange = abs(diff(xlim));
        frange = abs(diff(fitxlim));
        if frange>2*xrange || xrange>2*frange
            % drastic change in scale, re-compute limits
            newlim = xlim;
            doit = true;
        elseif fitxlim(1)>xlim(1) || fitxlim(2)<xlim(2)
            % minor change in scale, expand limits
            newlim = [min(xlim(1),fitxlim(1)), max(xlim(2),fitxlim(2))];
            doit = true;
        else
            % old scale is still okay, so avoid performance hit
            doit = false;
        end
    end
    if doit
        try
            updateplot(ft,newlim);
        catch
            % likely to be dealt with elsewhere
        end
    end
    ft = right(ft);
end


% ---------------------- helper to verify closing of figure
function closefig(varargin)
%CLOSEFIG Verify intention to close distribution fitting figure

ok = dfasksavesession;
if ok
    deletefig
end

function deletefig(varargin)
%DELETEFIG Close figure without verification
set(gcbf,'CloseRequestFcn','');

% Clear current session
dfsession('clear');

% Delete any dfittool-related figures
h = dfgetset('evaluateFigure');
if ~isempty(h) && ishghandle(h), delete(h); end
h = gcbf;
if ~isempty(h) && ishghandle(h), delete(h); end
dfdelgraphexclude;


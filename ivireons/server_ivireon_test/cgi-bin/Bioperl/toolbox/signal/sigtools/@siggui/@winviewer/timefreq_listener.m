function timefreq_listener(hView, eventData)
%TIMEFREQ_LISTENER Callback executed by listener to the Timedomain/Freqdomain properties.

%   Author(s): V.Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2009/01/05 18:01:23 $

% Resize axes, set visibility
stretch_axes(hView);

% Update the 'View' menu and the context menu
update_viewmenus(hView);

% Force the legend to be on top of the stack 
% because of interaction with the data markers
hFig = get(hView, 'FigureHandle');
holdlegend = findall(hFig, 'Tag', 'legend');
if ishghandle(holdlegend),
    axes(holdlegend);
end

%---------------------------------------------------------------------
function stretch_axes(hView)
%STRETCH_AXES Resize axes, set visibility

td = get(hView, 'Timedomain');
fd = get(hView, 'Freqdomain');

hndls = get(hView, 'Handles');
haxtd = hndls.axes.td;
haxfd = hndls.axes.fd;

% Resize axes, set visibility
axtdPos = get(haxtd, 'OuterPosition');
% Normalized values
axx1 = 0; 
axx2 = 0.5; % second axes (Frequency Domain)
axy = axtdPos(2);
axw1 = 0.5; % when there are two axes
axw2 = 1; % one axes only
axh = axtdPos(4);

if strcmpi(td, 'on') & strcmpi(fd, 'on'),
    % Time axes
    % Add normalized factor to preserve spacing ratio
    set(haxtd, ...
        'OuterPosition', [axx1 axy axw1 axh], ...
        'Visible',       'On'); 
    set(allchild(haxtd), 'Visible', 'On');
    
    % Frequency axes
    set(haxfd, ...
        'OuterPosition', [axx2 axy axw1 axh], ...
        'Visible',       'On');
    set(allchild(haxfd), 'Visible', 'On');
    
elseif strcmpi(td, 'on'),
    % Only time axes
    set(haxtd, ...
        'OuterPosition', [axx1 axy axw2 axh], ...
        'Visible',       'On');
    set(allchild(haxtd), 'Visible', 'On');

    % Turn freq axes invisible
    set(findobj(haxfd), 'Visible' , 'off');
    
elseif strcmpi(fd, 'on'),
    % Only frequency axes
    set(haxfd, ...
        'OuterPosition', [axx1 axy axw2 axh], ...
        'Visible',       'on');
    set(allchild(haxfd), 'Visible', 'On');

    % Turn time axes invisible
    set(findobj(haxtd), 'Visible' , 'off');
else
    % None
    set(findobj(haxtd), 'Visible' , 'off');
    set(findobj(haxfd), 'Visible' , 'off');
end

% Refresh legend
set(hView, 'Legend', get(hView, 'Legend'));

%---------------------------------------------------------------------
function update_viewmenus(hView)
%UPDATE_VIEWMENUS Update the 'View' menu and the context menu

td = get(hView, 'Timedomain');
fd = get(hView, 'Freqdomain');

hndls = get(hView, 'Handles');

% Time domain
timemenu = findobj([hndls.contextmenu hndls.menu], 'Tag', 'timedomain');
set(timemenu, 'Checked', td);

% Frequency domain
freqmenu = findobj([hndls.contextmenu hndls.menu], 'Tag', 'freqdomain'); 
set(freqmenu, 'Checked', fd);

% Enable/Disable the frequency YLabel contextmenu
hfline = findobj(hndls.axes.fd, 'Tag' , 'fline');
if isempty(hfline),
    % If  there's no data in the viewer
    enabState = 'off';
else,
    enabState =  fd;
end
set(hndls.frespunits, 'Enable', enabState);

% [EOF]

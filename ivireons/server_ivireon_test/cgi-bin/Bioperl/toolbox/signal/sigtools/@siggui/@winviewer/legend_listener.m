function legend_listener(hView, eventData)
%LEGEND_LISTENER Callback executed by listener to the Legend property.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2008/05/31 23:28:28 $

window_names = get(hView, 'Names');

% Old legend
hFig = get(hView, 'FigureHandle');
holdlegend = findall(hFig, 'Tag', 'legend');

% Get the handle to the freq axes and the legend menus
hndls = get(hView, 'Handles');
legendmenus = findobj([hndls.contextmenu hndls.menu], 'Tag', 'legendmenu');
haxfd = hndls.axes.fd;


legendState = get(hView, 'Legend');
switch legendState,
case 'on',
    
    if isempty(window_names),
       % If there's no data is the Viewer
       delete(holdlegend);
       
       % Disable legend menus and toggle
       set([hndls.legendbtn; legendmenus], 'Enable', 'off');
       
   else
       % Save the position of the old legend
       legpos = get(holdlegend, 'Position');
    
        % Create a new legend
        hlegend = legend(haxfd, window_names);
        
        % Restore the position of the top-left corner of the legend
        newpos = get(hlegend, 'Position');
        if ~isempty(legpos),
            topleft = [legpos(1) legpos(2)+legpos(4)];
            newpos(1) = topleft(1);
            newpos(2) = topleft(2)-newpos(4);
            set(hlegend, 'Position', newpos);
        end
        
       % Enable legend menus and toggle
       set([hndls.legendbtn; legendmenus], 'Enable', 'on');
        
    end
    
case 'off',
    
    if ~isempty(holdlegend),
        legend(haxfd, 'hide');
    end
    
end

% Check/Uncheck the menus
set(legendmenus, 'Checked', legendState);

% Set the state of the toogle button
set(hndls.legendbtn, 'State' , legendState);

% If there's no axes visible
td = get(hView, 'Timedomain');
fd = get(hView, 'Freqdomain');
if strcmpi(td, 'off') & strcmpi(fd, 'off'),
    % Hide the legend
    legend(haxfd, 'hide');
    % Disable legend menus and toggle
    set([hndls.legendbtn; legendmenus], 'Enable', 'off');
else
    % Enable legend menus and toggle
    set([hndls.legendbtn; legendmenus], 'Enable', 'on');
end

% Disable the ButtonDownFcn so that the legend is not editable
hleg = findall(hFig, 'Tag', 'legend');
hchild = get(hleg, 'children');
set(hchild, 'ButtonDownFcn', '');


% [EOF]


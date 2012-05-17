function desktopmenufcn(dtmenu, cmd)
% DESKTOPMENUFCN Implements the Desktop menu of undocked figure windows.

% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.13 $  $Date: 2010/05/20 02:29:52 $

error(nargchk(1,2,nargin))

if ischar(dtmenu)
    cmd = dtmenu;
    dtmenu = gcbo;
end

% But gcbo does not return the correct menu object sometimes when menu's
% CreateFcn is called.  
%
% In the following edge case , this menu item will be enabled
% in the native figure menubar if that figure is created
% without menubar, then javaFigures mode is turned on, and then
% menubar is turned on. In that case, it will be disabled by its
% Callback code in 'desktopmenupopulate' below when clicked.
if ~strcmpi(get(dtmenu, 'type'), 'uimenu')
    return;
end

fig = get(dtmenu,'Parent');

% possibly related to the above check on dtmenu, it can happen that 
% this callback has a partially defined figure which manifests as a 
% bogus DockControls property value. This happens even without Java
% figures turned on
if ~ischar(get(fig,'DockControls'))
  return;
end

switch lower(cmd)       
    case 'desktopmenupopulate'
        % disable the warning when using the 'JavaFrame' property
        % this is a temporary solution
%      if isempty(get(fig, 'JavaFrame'))
        oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        jf = get(fig, 'JavaFrame');
        warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        if isempty(jf)
            delete(allchild(dtmenu));
            set(dtmenu,'Visible','off')
        elseif ishghandle(dtmenu)
            % Java Figures is on and DockControls is on. 
            % This is a Java Figure. So, populate the desktop menu.
            h = allchild(dtmenu);
            if isempty(h)
                h = uimenu(dtmenu);
            end
            
            name = get(fig, 'name');
            t = '';
            if strcmp(get(fig,'numbertitle'),'on')
                t = sprintf('Figure %.8g',double(fig));
                if ~isempty(name)
                    t = [t, ': '];
                end
            end
            title = [t, name];
            
            if (strcmp(get(fig, 'windowstyle'), 'docked'))
                set(h, 'label', sprintf('Undock %s', title), 'callback', ...
                    {@figureDockingHandler, fig, 'off'});
            else
                set(h, 'label', sprintf('Dock %s', title), 'callback', ...
                    {@figureDockingHandler, fig, 'on'});
            end

            % Make the menu visible as it may not be by default.
            set(h, 'Visible', 'on');
            if (strcmp(get(fig, 'DockControls'), 'off'))
            % The DockControls property must be on for the 
            % figure to support docking.
                set(h, 'Enable', 'off');
            else
                set(h, 'Enable', 'on');
            end
        end
end


function figureDockingHandler(src, evd, figh, isDock)
if isDock
    set(figh, 'windowstyle', 'docked');
else
    set(figh, 'windowstyle', 'normal');
end

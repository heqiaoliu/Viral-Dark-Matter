function comp = showplottool (varargin)
% SHOWPLOTTOOL Show or hide one of the plot-editing components for a figure.
%    SHOWPLOTTOOL ('figurepalette') shows the palette for the current figure.
%    SHOWPLOTTOOL ('on', 'figurepalette') also shows the palette for the current figure.
%    SHOWPLOTTOOL ('off', 'figurepalette') hides it.
%    SHOWPLOTTOOL ('toggle', 'figurepalette') toggles its visibility.
%
% The first argument may be the handle to a figure, like so:
%    SHOWPLOTTOOL (h, 'on', 'figurepalette')
%
% The last argument should be one of 'figurepalette', 'plotbrowser', or 'propertyeditor'.

% Copyright 2003-2007 The MathWorks, Inc.


error (nargchk (1,3,nargin))

if ispref('plottools', 'isdesktop')
    rmpref('plottools', 'isdesktop');
end

% Standardize the arguments into fig, arg, and compName:
if nargin == 1                  % ('plotbrowser')
    % if no figures exist, fig = []
    if isempty(get(0,'children'))
        fig = [];
    else
        fig = gcf;
    end
    arg = 'on';
    compName = lower (varargin{1});
elseif nargin == 2
    if ischar (varargin{1})      % ('off', 'plotbrowser')
        if isempty(get(0,'children'))
            fig = [];
        else
            fig = gcf;
        end
        arg = lower (varargin{1});
    else
        fig = varargin{1};      % (h, 'plotbrowser')
        arg = 'on';
    end
    compName = lower (varargin{2});
else
    fig = varargin{1};          % (h, 'off', 'plotbrowser')
    arg = lower (varargin{2});
    compName = lower (varargin{3});
end

if isempty(fig)
    fig = gcf;
    drawnow;
elseif feature('HGUsingMATLABClasses')
    fig = handle(fig); % No double or integer fig handles
end

if ~usejava('swing')
    error('MATLAB:showplottool:NotSupportedForPlatform',...
        'The plot tools are not supported on this platform.');
end


if ~com.mathworks.page.plottool.WaitBar.hasOpened
    % Make sure any figure closing events have been processed before 
    % attempting to dock the figure into the Plot Tools for the 
    % first time. This avoids race conditions where a figure closes
    % during the initial plot tools creation (which can be slow).
    drawnow 
    if ((ishandle(fig) && ~feature('HGUsingMATLABClasses')) || ...
             (isobject(fig) && feature('HGUsingMATLABClasses'))) && ...   
             strcmp(get(fig,'BeingDeleted'),'off')
        com.mathworks.page.plottool.WaitBar.open(get(fig,'Position'),java(handle(fig)));
    else
        comp = [];
        return
    end
end

% Do nothing if the figure is really a dialog:
if strncmpi (get(handle(fig),'Tag'), 'Msgbox', 6) || ...
        strcmpi (get(handle(fig),'WindowStyle'), 'Modal')
    comp = [];
    return
end

% Convert name argument to the desktop "short title":
if strcmp (compName, 'plotbrowser')
    compName = 'Plot Browser';
elseif strcmp (compName, 'figurepalette')
    compName = 'Figure Palette';
elseif strcmp (compName, 'propertyeditor')
    compName = 'Property Editor';
end

% Find the correct group name and desktop:
jf = javaGetFigureFrame(fig);
if ~isempty(jf)
    dt = jf.getDesktop; 
    if isempty(dt)
        groupName = 'Figures';
        dt = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;       
    else
        groupName = jf.getGroupName;
    end
else
    groupName = 'Figures';
    dt = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
end

isDocked = strcmp(get(fig,'WindowStyle'),'docked');

% Figure out if 'toggle' means 'on' or 'off':
if (strcmp(arg, 'toggle') ~= 0)
    if dt.isClientShowing (compName, groupName) && isDocked
        arg = 'off';
    else
        arg = 'on';
    end
end

% Do it:
comp = awtinvoke (dt, 'getClient(Ljava.lang.String;Ljava.lang.String;)', compName, groupName);
switch (arg)
    case {'on', 'show'}
        plotedit(fig,'on');
        if ~dt.isGroupShowing (groupName) && ...
                strcmpi (get(fig, 'WindowStyle'), 'docked') == 0
            dt.showGroup (groupName, true);
            dt.setGroupDocked (groupName, false);
        end
        set(fig, 'WindowStyle', 'docked');
        % These are called inside "awtinvoke" because showClient and hideClient
        % would otherwise return before they are finished.  That's bad because
        % the call to getClient (below) could sometimes return null.
        
        if isempty(comp)
            comp = getplottool (fig, compName);
            if isempty(comp)
                error('MATLAB:showplottool:NoHandleReturned',...
                    'No component handle returned from the desktop')
            end
        end
        awtinvoke (dt, 'showClient(Ljava.lang.String;Ljava.lang.String;)', compName, groupName)

    case {'off', 'hide'}
        awtinvoke (dt, 'hideClient(Ljava.lang.String;Ljava.lang.String;)', compName, groupName)
        % don't bother erroring if comp is empty; it may not have been created
        % yet anyhow.  (g316803)

    case 'get'
        % do nothing; just return it
        if isempty(comp)
            error('MATLAB:showplottool:NoHandleReturned',...
                'No component handle returned from the desktop')
        end
end
% drawnow

enableplottoolbuttons (fig);


function plot(h)
%PLOT  Plot multipath channel data in multipath figure object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/06/08 15:52:09 $

if (~h.HistoryStored)
    if (~h.StoreHistory)
        error('comm:channel_multipath_plot:noplotdatastorehistory', ...
            ['No plot data stored in channel object.  ' ...
            'Set property StoreHistory to 1 ' ...
            'before using filter method.']);
    else
        error('comm:channel_multipath_plot:noplotdatafilter', ...
            ['No plot data stored in channel object.  ' ...
            'Use the filter method before using plot.']);        
    end
end

if (size(h.PathGains, 1) == 1)
    error('comm:channel_multipath_plot:onesample', ...
           ['Must have more than one channel sample (snapshot) ' ...
           'stored in channel object. ' ...
           'Use the filter method with more than one input sample.']);
end

% Temporarily shows all handles, since the command
% set(f.FigureHandle,'HandleVisibility','callback') below makes the handle
% of the multipath figure invisible
set(0,'ShowHiddenHandles','on');

% Get multipath figure object associated with channel object.
f = h.MultipathFigure;

if isempty(h.Simulink)
    
    % MATLAB mode: Multipath object not associated with Simulink block.

    % Check to see whether current figure window is not associated with the
    % multipath figure object.  This will create a figure if none exists.
    ud = get(gcf, 'userdata');
    if (~isequal(f, ud))
        % Multipath object is created, or is to be created, in MATLAB.
        if isequal(class(ud), 'channel.multipathfig')
            % The figure window maps to another multipath figure object.
            % We want to use this as the current multipath figure object.
            f = ud;
        else
            set(0,'ShowHiddenHandles','off');
            % Otherwise, create a new multipath figure object.
            if ~isempty(ud) || ~isempty(get(gcf, 'child'))
                % Create new figure if figure is not empty.
                figure;
            end
            set(0,'ShowHiddenHandles','on');
            f = channel.multipathfig;
            set(gcf, 'integerhandle', 'off');
            initfig(h, f, gcf, false);
        end
        % Set channel object's multipath figure object.
        h.MultipathFigure = f;
        
    end
    
    if (h.FigNeedsToBeInitialized)
        initfig(h, f, f.FigureHandle, false);
    end

else
    
    % Simulink mode: Multipath object is associated with Simulink block.
    if isempty(f.FigureHandle)
        fig = figure('integerhandle', 'off');
        h.FigNeedsToBeInitialized = true;
    else
        fig = f.FigureHandle;
    end
    
    if (h.FigNeedsToBeInitialized)
        initfig(h, f, fig, true);
    end
 
end

set(0,'ShowHiddenHandles','off');

% To allow updating the figure after it has been created, and its
% HandleVisibility property has been set to 'callback
set(f.FigureHandle,'HandleVisibility','on');

% Plot multipath channel object in multipath figure.
f.plot(h);

% To avoid command-line overwriting of the figure
set(f.FigureHandle,'HandleVisibility','callback');

%--------------------------------------------------------------------------
function initfig(h, f, fig, isSimulink)
if ~isSimulink
    f.initialize(fig);
else
    f.initialize(fig, h.Simulink);
end
h.FigNeedsToBeInitialized = false;
h.FigNeedsToBeReset = false;



classdef DoubleYAxes < sigutils.pvpairs
    % DoubleYAxes Construct a double Y axes object
    % This object manages an axes with one Y-axis on the left and one on the
    % right, sharing a single X-axis.
    %
    %   Warning: This undocumented function may be removed in a future release.

    % Copyright 2008-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.7.2.1 $  $Date: 2010/07/23 15:34:41 $

    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        Container           % Stores the handle to the container
        LeftYAxis = -1      % Stores the handle to the left axis
        RightYAxis = -1     % Stores the handle to the right axis
        XData
        Children            % Stores a structure that contains the information 
                            % on the children (line, etc.) of this axes.  The 
                            % structure has following fields:
                            %   Handle
                            %   LeftAxis : true/false
        LegendHandle = -1;
        LeftYMarker = '*';  % Marker used to identify left axis.  Note 
                            % that, if there are no lines left on the left axis,
                            % eight axis is move to the left. 
        RightYMarker = 'o'; % Marker used to identify right axis.  Note 
                            % that, if there are no lines left on the left axis,
                            % eight axis is move to the left. 
        State = 'Normal';   % Determines the sate of the double Y-axis object.  
                            % Can be: 
                            %   Normal: 
                            %   Warning: a third axis was tried to be included
        WarningAxis         % Handle of the warning axis
        Listeners           % ObjectBeingDestroyed listener to remove axes.
        OldLeftYLim         % Y limits of left axes before zoom
        OldRightYLim        % Y limits of right axes before zoom
    end

    %===========================================================================
    % Public Dependent properties
    properties (Dependent)
        LeftYLabel
        RightYLabel
        XLabel
        Title
        Parent
        FontSize
        Units
        Position
    end

    %===========================================================================
    % Public properties
    properties 
        Legend = 'on'
        Tag = '';
    end
    %===========================================================================
    % Public methods
    methods
        function this = DoubleYAxes(parent, varargin)
            
            this.Children = commutils.SListMgr;
            
            % Create a container
            this.Container = uicontainer('Parent', parent);

            % Put the axes in the container
            this.LeftYAxis = axes('Parent', this.Container, ...
                'NextPlot', 'add', ...
                'Box', 'on', ...
                'Tag', 'LeftYAxis');
            this.RightYAxis = axes('Parent', this.Container, ...
                'NextPlot', 'add', ...
                'YAxisLocation', 'right', ...
                'Box', 'on', ...
                'Color', 'none', ...
                'Visible', 'off', ...
                'HitTest', 'off', ...
                'Tag', 'RightYAxis');
            
            % Make left axes the current axes so that the legend button (if
            % exists) controls the correct axes.
            hFig = ancestor(parent, 'figure');
            set(hFig, 'CurrentAxes', this.LeftYAxis);
            
            if nargin>2
                initPropValuePairs(this, varargin{:});
            end

            % Set the resize callback function to keep the axes in sync
            set(this.Container, 'ResizeFcn', @(hsrc,edata)alignAxes(this))

            % Set the zoom callback function to keep the axes in sync
            set(zoom(hFig), 'ActionPostCallback', ...
                @(hsrc,edata)cbZoomActionPostCallback(this))
            set(zoom(hFig), 'ActionPreCallback', ...
                @(hsrc,edata)cbZoomActionPreCallback(this))
            
            % Disallow panning with mouse
            setAllowAxesPan(pan(hFig),this.LeftYAxis,false)
            setAllowAxesPan(pan(hFig),this.RightYAxis,false)

            % Store the object in the container so that there will be at least
            % one reference to the object
            setappdata(this.Container, 'DoubleYAxes', this);
            
            % Set a listener to destroy the object
            this.Listeners = ...
                addlistener(this,...
                    'ObjectBeingDestroyed',...
                    @(hsrc,edata)cbObjectBeingDestroyed(this));
        end
        %-----------------------------------------------------------------------
        function addLine(this, x, y, yLabel, style, legendStr)
            % Add a line plot to the axes.  Based on the yLabel, place it to
            % left or the right axis.  First line goes to the left.  If another
            % yLabel is specified with a new line, it goes to the right axis.
            % If a third one is specified, it is not plotted.

            if nargin < 5
                style.Color = [0 0 1];
                style.LineStyle = '-';
            end
            if nargin < 6
                legendStr = '';
            end

            % check XData
            if ~this.Children.NumberOfElements
                % This is the first line to be drawn
                this.XData = x;
            else
                % There are lines.  Check if the XData matches
                if (this.XData ~= x)
                    error('comm:commgui:DoubleYAxes:WrongX', ...
                        'X values do not match current plot')
                end
            end

            % Check the yLabel(s) and plot to the matching axis
            if strcmp(this.LeftYLabel, yLabel)
                % It matches the left axis
                plot2Left(this, x, y, style, legendStr)
            elseif strcmp(this.RightYLabel, yLabel)
                % It matches the right axis
                plot2Right(this, x, y, style, legendStr)
            else
                % It did not match the left or right.  Check if either is empty
                if ~isLeftAxisInUse(this)
                    % This is the first line for the left axis
                    this.LeftYLabel = yLabel;
                    plot2Left(this, x, y, style, legendStr)
                elseif ~isRightAxisInUse(this)
                    % This is the first line for the right axis
                    this.RightYLabel = yLabel;
                    plot2Right(this, x, y, style, legendStr)
                else
                    switch2Warning(this, legendStr, yLabel)
                end
            end

            % Update the legend
            if strcmp(this.Legend, 'on')
                updateLegend(this)
            end

            % Align the axes so the position properties and ticks match
            alignAxes(this)
        end
        %-----------------------------------------------------------------------
        function deleteChild(this, idx)
            % Remove the line from the plot and the line handles
            lines = this.Children;
            child = delete(lines, idx);
            % Determine if the child is a dummy handle (causing warning) or a
            % regular handle. 
            if isempty(child.Handle{:}(1))
                child.Handle{:} = child.Handle{:}(2);
            end
            delete(child.Handle{:})

            % Check if this was the only line on either of the axis
            if (getRightChildrenCnt(this) == 0)
                this.RightYLabel = '';
            elseif (getLeftChildrenCnt(this) == 0)
                if isRightAxisInUse(this)
                    % Left axis is empty but right axis is not.  Move the right
                    % axis to left
                    moveRight2Left(this)
                else
                    this.LeftYLabel = '';
                end
            end

            if strcmp(this.State, 'Warning')
                checkWarning(this)
            end

            % Update the legends
            if strcmp(this.Legend, 'on')
                updateLegend(this)
            end

            % Align the axes so the position properties and ticks match
            alignAxes(this)
        end
        %-----------------------------------------------------------------------
        function deleteAll(this)
            % Empty the Children list
            lines = this.Children;
            for p=1:lines.NumberOfElements
                delete(lines, 1);
            end
            
            % Remove all the lines from the right axis and make it unused
            if isRightAxisInUse(this)
                delete(get(this.RightYAxis, 'Children'))
                this.RightYLabel = '';
            end
            
            % Remove all the lines from the left axis and make it unused
            delete(get(this.LeftYAxis, 'Children'))
            this.LeftYLabel = '';
            
            % Update the legend
            if strcmp(this.Legend, 'on')
                updateLegend(this)
            end

            % Update the warning state
            if strcmp(this.State, 'Warning')
                checkWarning(this)
            end
        end
        %-----------------------------------------------------------------------
        function that = copyobj(this, hParent)
            %COPYOBJ Copy the double-Y axes
            %    C = COPYOBJ(H, PARENT) copies the double-Y axes, H, parented
            %    under the corresponding object specified in the vector P, and
            %    returns in the double-Y axes, C.
            
            % Create a new double-Y axes
            that = commgui.DoubleYAxes(hParent);
            
            % Add the lines one-by-one
            lines = getElements(this.Children);
            for p=1:length(lines)
                hLine = lines(p).Handle{1};
                if length(hLine) > 1
                    hLine = hLine(1);
                end
                style.Color = get(hLine, 'Color');
                style.LineStyle = get(hLine, 'LineStyle');
                if lines(p).LeftAxis
                    labelStr = this.LeftYLabel;
                else
                    labelStr = this.RightYLabel;
                end
                addLine(that, get(hLine, 'XData'), get(hLine, 'YData'), ...
                    labelStr, style, get(hLine, 'DisplayName'))
            end
            
            % Align axes
            alignAxes(that)
            
            % Copy legend state
            that.Legend = this.Legend;
        end
    end

    %===========================================================================
    % Set/Get methods
    methods
        function set.LeftYLabel(this, yLabel)
            if ~isempty(yLabel)
                yLabel = sprintf('%s (%s)', yLabel, this.LeftYMarker);
            end
            set(get(this.LeftYAxis, 'YLabel'), 'String', yLabel);
        end
        %-----------------------------------------------------------------------
        function yLabel = get.LeftYLabel(this)
            yLabel = get(get(this.LeftYAxis, 'YLabel'), 'String');
            yLabel = strrep(yLabel, [' (' this.LeftYMarker ')'], '');
        end
        %-----------------------------------------------------------------------
        function set.RightYLabel(this, yLabel)
            set(get(this.RightYAxis, 'YLabel'), 'String', ...
                sprintf('%s (%s)', yLabel, this.RightYMarker));
            if isempty(yLabel)
                % Since the YLabel is empty, make it invisible
                set(this.RightYAxis, 'Visible', 'off')
            else
                % Since the YLabel has a value, make it visible
                set(this.RightYAxis, 'Visible', 'on')
            end
        end
        %-----------------------------------------------------------------------
        function yLabel = get.RightYLabel(this)
            if ishghandle(this.RightYAxis)
                yLabel = get(get(this.RightYAxis, 'YLabel'), 'String');
                yLabel = strrep(yLabel, [' (' this.RightYMarker ')'], '');
            else
                yLabel = '';
            end
        end
        %-----------------------------------------------------------------------
        function set.XLabel(this, xLabel)
            set(get(this.LeftYAxis, 'XLabel'), 'String', xLabel);
        end
        %-----------------------------------------------------------------------
        function xLabel = get.XLabel(this)
            xLabel = get(get(this.LeftYAxis, 'XLabel'), 'String');
        end
        %-----------------------------------------------------------------------
        function set.Title(this, value)
            set(get(this.LeftYAxis, 'Title'), 'String', value);
        end
        %-----------------------------------------------------------------------
        function value = get.Title(this)
            value = get(get(this.LeftYAxis, 'Title'), 'String');
        end
        %-----------------------------------------------------------------------
        function set.FontSize(this, value)
            set(this.LeftYAxis, 'FontSize', value);
            set(this.RightYAxis, 'FontSize', value);
        end
        %-----------------------------------------------------------------------
        function value = get.FontSize(this)
            value = get(this.LeftYAxis, 'FontSize');
        end
        %-----------------------------------------------------------------------
        function set.Units(this, value)
            set(this.Container, 'Units', value);
        end
        %-----------------------------------------------------------------------
        function value = get.Units(this)
            value = get(this.Container, 'Units');
        end
        %-----------------------------------------------------------------------
        function set.Position(this, value)
            % Set the position of the container.  The axes use this as the outer
            % position
            set(this.Container, 'Position', value);
        end
        %-----------------------------------------------------------------------
        function value = get.Position(this)
            value = get(this.Container, 'Position');
        end
        %-----------------------------------------------------------------------
        function set.Parent(this, hParent)
            set(this.LeftYAxis, 'Parent', hParent);
            set(this.RightYAxis, 'Parent', hParent);
            if ishghandle(this.LegendHandle)
                set(this.Legend, 'Parent', hParent);
            end
        end
        %-----------------------------------------------------------------------
        function hParent = get.Parent(this)
            hParent = get(this.LeftYAxis, 'Parent');
        end
        %-----------------------------------------------------------------------
        function set.Legend(this, val)
            this.Legend = val;
            updateLegend(this)
            if ishghandle(this.LegendHandle) %#ok<*MCSUP>
                set(this.LegendHandle, 'Visible', val)
            end
        end
    end

    %===========================================================================
    % Private methods
    methods (Access = private)
        function add2Children(this, hChild, leftAxis)
            elem.Handle = hChild;
            elem.LeftAxis = leftAxis;
            add(this.Children, elem);
        end
        %-----------------------------------------------------------------------
        function plot2Left(this, x, y, style, legendStr)
            style.Marker = this.LeftYMarker;
            
            if strcmp(this.State, 'Warning')
                visible = 'off';
            else
                visible = 'on';
            end
            
            h = plot(this.LeftYAxis, x, y, ...
                'DisplayName', legendStr, ...
                'Color', style.Color, ...
                'LineStyle', style.LineStyle, ...
                'Marker', style.Marker, ...
                'Visible', visible);

            % Plot an invisible copy to the right axis to enable zoom
            hc = plot(this.RightYAxis, x, y, ...
                'DisplayName', legendStr, ...
                'Color', style.Color, ...
                'LineStyle', style.LineStyle, ...
                'Marker', style.Marker, ...
                'Visible', 'off');

            % Add the new line to the Children
            add2Children(this, {[h hc]}, true)
        end
        %-----------------------------------------------------------------------
        function plot2Right(this, x, y, style, legendStr)
            style.Marker = this.RightYMarker;
            
            h = plot(this.RightYAxis, x, y, ...
                'DisplayName', legendStr, ...
                'Color', style.Color, ...
                'LineStyle', style.LineStyle, ...
                'Marker', style.Marker);
            
            % Plot an invisible copy to the left axis to generate axis
            hc = plot(this.LeftYAxis, x, y, ...
                'DisplayName', legendStr, ...
                'Color', style.Color, ...
                'LineStyle', style.LineStyle, ...
                'Marker', style.Marker, ...
                'Visible', 'off');

            % Add the new line to the Children
            add2Children(this, {[h hc]}, false)
        end
        %-----------------------------------------------------------------------
        function cnt = getRightChildrenCnt(this)
            children = getElements(this.Children);
            cnt = 0;
            for p=1:length(children)
                if ~children(p).LeftAxis
                    cnt = cnt + 1;
                end
            end
        end
        %-----------------------------------------------------------------------
        function cnt = getLeftChildrenCnt(this)
            children = getElements(this.Children);
            cnt = 0;
            for p=1:length(children)
                if children(p).LeftAxis
                    cnt = cnt + 1;
                end
            end
        end
        %-----------------------------------------------------------------------
        function updateLegend(this)
            legend(this.LeftYAxis, 'off')
            if strcmp(this.State, 'Normal') && getLeftChildrenCnt(this)
                this.LegendHandle = legend(this.LeftYAxis, 'Toggle');
                set(this.LegendHandle, 'Location', 'Best');
            end
        end
        %-----------------------------------------------------------------------
        function moveRight2Left(this)
            % Move the children of the right axis to the left axis
            temp = this.LeftYAxis;
            this.LeftYAxis = this.RightYAxis;
            set(this.LeftYAxis, ...
                'YAxisLocation', 'left', ...
                'Color', [1 1 1], ...
                'Tag', 'LeftYAxis');
            title(this.LeftYAxis, get(get(temp, 'Title'), 'String'));
            xlabel(this.LeftYAxis, get(get(temp, 'XLabel'), 'String'));
            % Make the old left axis the new right axis
            set(temp, 'Tag', 'RightYAxis');
            delete(get(temp, 'Children'))
            this.RightYAxis = temp;
            this.RightYLabel = '';

            % Set the LeftAxis flag to true.  Also, remove the left axis copy
            % from the Handles field, since the lines are already in the left
            % axis.
            children = this.Children;
            for p=1:children.NumberOfElements
                setSelectedElement(children, 1);
                elem = delete(children, 1);
                elem.LeftAxis = true;
                elem.Handle = elem.Handle;
                add(children, elem);
            end
            
            temp = this.RightYMarker;
            this.RightYMarker = this.LeftYMarker;
            this.LeftYMarker = temp;
        end
        %-----------------------------------------------------------------------
        function switch2Warning(this, legendStr, yLabel)
            % Add the new line to the Children as a dummy line.  Store the
            % yLabel in the user data.
            hdummy = plot(this.RightYAxis, 0, 0, ...
                'DisplayName', legendStr, ...
                'UserData', yLabel, ...
                'Visible', 'off');
            hInvalid = plot([]);
            delete(hInvalid)
            add2Children(this, {[hInvalid hdummy]}, false)
            
            if strcmp(this.State, 'Normal')
                % Switch from Normal state to Warning state
                this.State = 'Warning';

                % Make both left and right axes invisible and 
                set(this.LeftYAxis, 'Visible', 'off')
                set(this.RightYAxis, 'Visible', 'off')
                
                % Make all the lines invisible
                elems = getElements(this.Children);
                for p=1:length(elems)
                    h = elems(p).Handle{:};
                    if ~isempty(h(1))
                        set(h(1), 'Visible', 'off')
                    end
                end
                
                % render a new empty axes with the warning message.
                temp = this.LeftYAxis;
                this.WarningAxis = axes(...
                    'Parent', get(temp, 'Parent'), ...
                    'units', get(temp, 'units'), ...
                    'Position', get(temp, 'Position'), ...
                    'XTick', [], ...
                    'YTick', [], ...
                    'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
                    'NextPlot', 'add', ...
                    'Box', 'on');
            end
            
            % Render the warning message.
            renderWarningMsg(this, legendStr, yLabel)
        end
        %-----------------------------------------------------------------------
        function renderWarningMsg(this, legendStr, yLabel)
            if ishghandle(this.WarningAxis)
                % Remove the warning message.  We will update it.
                delete(get(this.WarningAxis, 'Children'));
            end
            
            msg = sprintf(['Cannot plot more than two Y axes.\nRemove the ', ...
                'line with\n\nLegend: ''%s''\n\nand\n\nYLabel: ''%s''.'], ...
                legendStr, yLabel);
            text(0, 0, msg, 'Parent', this.WarningAxis, ...
                'FontSize', get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment', 'center',...
                'units', 'normalized', ...
                'Position', [0.5 0.5], ...
                'Tag', 'DoubleYAxesWarningMessage');
        end
        %-----------------------------------------------------------------------
        function checkWarning(this)
            % Check if the warning state condition is satisfied.  If not switch
            % to normal state.
            
            flag = false;
            
            elems = getElements(this.Children);
            for p=1:length(elems)
                if isempty(elems(p).Handle{:}(1))
                    flag = true;
                    h = elems(p).Handle{:}(2);
                    renderWarningMsg(this, get(h, 'DisplayName'), ...
                        get(h, 'UserData'))
                    break
                end
            end
            
            if ~flag
                %  The warning condition is not satisfied.  Return to normal
                %  state.
                switch2Normal(this)
            end
                    
        end
        %-----------------------------------------------------------------------
        function switch2Normal(this)

            % Set the state
            this.State = 'Normal';
            
            % Make both left and right axes visible
            set(this.LeftYAxis, 'Visible', 'on')
            if ishghandle(this.RightYAxis)
                set(this.RightYAxis, 'Visible', 'on')
            end

            % Make all the lines visible
            elems = getElements(this.Children);
            for p=1:length(elems)
                h = elems(p).Handle{:};
                set(h(1), 'Visible', 'on')
            end

            % Render remove the warning axis
            delete(this.WarningAxis)
        end
        %-----------------------------------------------------------------------
        function flag = isRightAxisInUse(this)
            flag = ~isempty(this.RightYLabel);
        end
        %-----------------------------------------------------------------------
        function flag = isLeftAxisInUse(this)
            flag = ~isempty(this.LeftYLabel);
        end
        %-----------------------------------------------------------------------
        function alignAxes(this)
            if isRightAxisInUse(this)
                % There are two axes.  Align the grids.
                setcoincidentgrid([this.LeftYAxis this.RightYAxis]);

                % Since we added y-labels to the right axis, we may have
                % changed the "position" of the right axis.  We need to
                % make sure that it matched the "position" property of the
                % left axis.
                rPos = get(this.RightYAxis, 'Position');
                lPos = get(this.LeftYAxis, 'Position');
                
                if any(rPos ~= lPos)
                    % Always use the right axis position as the true one
                    set(this.LeftYAxis, 'Position', rPos)
                    set(this.LeftYAxis, 'ActivePositionProperty', ...
                        'outerposition');
                end
            end
        end
    end
end

%===============================================================================
% Helper/Callback functions

function cbObjectBeingDestroyed(this)
% Delete the double Y-axes object.  Delete the child axes.

if isvalid(this) || isa(this, 'commgui.DoubleYAxes')
    if ishghandle(this.LeftYAxis)
        delete(this.LeftYAxis);
    end
    if ishghandle(this.RightYAxis)
        delete(this.RightYAxis);
    end
    if ishghandle(this.WarningAxis)
        delete(this.WarningAxis)
    end
    if ishghandle(this.Container)
        delete(this.Container)
    end
end
end
%-------------------------------------------------------------------------------
function cbZoomActionPreCallback(this)
this.OldLeftYLim = get(this.LeftYAxis, 'YLim');
this.OldRightYLim = get(this.RightYAxis, 'YLim');
this.OldLeftXLim = get(this.LeftYAxis, 'XLim');
this.OldRightXLim = get(this.RightYAxis, 'XLim');
end
%-------------------------------------------------------------------------------
function cbZoomActionPostCallback(this)
% Determine the reference axis
if get(this.RightYAxis, 'XLim') == this.OldRightXLim
    refAxis = this.LeftYAxis;
    refAxisOldYLim = this.OldLeftYLim;
    axisToSetOldYLim = this.OldRightYLim;
    axisToSet = this.RightYAxis;
elseif get(this.LeftYAxis, 'XLim') == this.OldLeftXLim
    refAxis = this.RightYAxis;
    refAxisOldYLim = this.OldRightYLim;
    axisToSetOldYLim = this.OldLeftYLim;
    axisToSet = this.LeftYAxis;
end

% Set the x limits
set(axisToSet, 'XLim', get(refAxis, 'XLim'))

% Get old and new limits and ranges
newRefAxisYLim = get(refAxis, 'YLim');
oldRefAxisYLim = refAxisOldYLim;
oldAxisToSetYLim = axisToSetOldYLim;
oldLeftYRange = oldAxisToSetYLim(2)-oldAxisToSetYLim(1);
oldRightYRange = oldRefAxisYLim(2)-oldRefAxisYLim(1);

% Determine the ratio of new Y limits based on old limits
ratio1 = (newRefAxisYLim(1)-oldRefAxisYLim(1))/oldRightYRange;
ratio2 = (newRefAxisYLim(2)-oldRefAxisYLim(1))/oldRightYRange;

% Calculate the new y limits based on the x limit ratios
newAxisToSetLim(2) = ratio2*oldLeftYRange+oldAxisToSetYLim(1);
newAxisToSetLim(1) = ratio1*oldLeftYRange+oldAxisToSetYLim(1);

% Set the new y limits
set(axisToSet, 'YLim', newAxisToSetLim)

alignAxes(this)
end

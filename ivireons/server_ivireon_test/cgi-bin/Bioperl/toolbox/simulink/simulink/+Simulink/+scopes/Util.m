classdef Util
    %  Utilities for Simulink Scope, called by simscope.m
    %
    %  Keep this file free of calls to gcb, gcbo, gcbf
    %  Pass the block, figure, or scopeUserData as argument instead
    %
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.2.2.2 $  $Date: 2010/07/23 15:43:53 $

    methods (Static)
            
        
       function [block, fig, userData] = GetFromFig()
            % In callback of a figure
            block = []; 
            userData = [];
            fig = gcbf;

            if fig ~= INVALID_HANDLE
                userData=get(fig,'UserData');
                block = userData.block;        
            end
        end
        
        function  [block, fig, userData] = GetFromBlock(varargin)
            
            % Proceed carefully, figure may not be open yet
            if isempty(varargin)
                % Current block is scope
                blkname = gcb;
                if ~isempty(blkname)
                    % get the scope's block figure
                    block = get_block_param(blkname, 'handle');
                else
                    block = [];
                end
            else
                block = varargin{1};
            end
            
            fig = [];
            userData = [];
            % Proceed carefully, figure may not be open yet
            if ishandle(block)
                % get the scope's block figure
                fig = get_block_param(blkname, 'Figure');
            end
            if ishandle(fig)
                userData = get(fig, 'UserData');
            end
        end % GetFromBlock
		
        function out = struct2cell(structMat)
            %% NOT NEEDED
            
            
            % Function: struct2cell =====================================================
            % Abstract:
            %    Convert from a cell to a structure array.  Same as struct2cell, but
            %    handles empty matrices for input arguments.
            if isempty(structMat)
                out = {};
            else
                out = struct2cell(structMat);
            end
            
        end % struct2cell
        
        
        % Function: DeleteAxesPropDlgs ==============================================
        % Abstract:
        %    Delete any open axes property dialogs.
        function DeleteAxesPropDlgs(scopeUserData)
            
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            
            for i=1:nAxes,
                ax         = scopeAxes(i);
                axUserData = get(ax, 'UserData');
                if ishandle(axUserData.propDlg)
                    delete(axUserData.propDlg);
                end
            end
            
        end
        
        % Function: AxesExtent =======================================================
        % Abstract:
        %    Calculates the "Extent" required to display the Y-axis tick labels
        
        function axExt = AxesExtent(scopeUserData)
            numAxis = size(scopeUserData.scopeAxes,2);
            extentStr = '1.0001';
            maxWidth = length(extentStr);
            if (numAxis > 0)
                %scan axes for largest y-axis tick label string
                for nAxis=1:numAxis
                    yTickLabelWidth = size(get(scopeUserData.scopeAxes(nAxis),'YTickLabel'),2);
                    if (yTickLabelWidth > maxWidth)
                        maxWidth = yTickLabelWidth;
                        yTickLabel = get(scopeUserData.scopeAxes(nAxis),'YTickLabel');
                        % pad 'Extent' with string '1' in case edge tick label 'Extent' is smaller
                        % this prevents clipping left-most pixels in tick label string
                        extentStr = [yTickLabel(1,:),'1'];
                    end
                end
            end
            % Encode largest encountered tick label
            set(scopeUserData.textExtent, ...
                'FontName',       scopeUserData.axesFontName, ...
                'FontSize',       scopeUserData.axesFontSize, ...
                'String',         extentStr ...
                );
            axExt = get(scopeUserData.textExtent, 'Extent');
            
        end % AxesExtent
        
        % Function: CreateAxesGeom ==================================================
        % Abstract:
        %    Create the geometry constants and other info required to calculate the
        %    positions of the axes.
        
        function axesGeom = CreateAxesGeom(scopeFig, scopeUserData)
                 
            %
            % g464733, 499614 and related gecks.
            %  Here we update the units of the textExtent and the axes so that they always match
            %  the units of the scope figure they are associated with. Not doing so will cause
            %  issues asseen in the gecks above since the scopeUserData does not automatically
            %  units of its fields when the units of the figure changes.
            %
            if ishandle(scopeFig)
                figUnits = get(scopeFig,'Units');
                set(scopeUserData.textExtent,'Units', figUnits);
                set(scopeUserData.scopeAxes,'Units', figUnits);
                set(scopeFig,'UserData',scopeUserData);
            end
            
            block = scopeUserData.block;
            axesGeom.showTitles   = 0;
            axesGeom.tickLabelOpt = get_block_param(block, 'TickLabels');
            
            %
            % Define constants.
            %
            axExt = Simulink.scopes.Util.AxesExtent(scopeUserData);
            tickLabelWidth  = axExt(3);
            
            set(scopeUserData.textExtent, ...
                'FontName',       scopeUserData.uiFontName, ...
                'FontSize',       scopeUserData.uiFontSize, ...
                'String',         'Time offset:' ...
                );
            uiExt = get(scopeUserData.textExtent, 'Extent');
            
            expFactor = 1.55;  % leave room for exponents;
            
            %
            % Define geometry constants:
            %   hTitle         - height of the titles including space between top of
            %                    axes and bottom of text
            %   hYTickLabelExp - height of exponent for y-axis
            %   hTimeOffset    - height of time offset including dead space above it. we
            %                    allocate some extra space so that the axes starts high
            %                    enough above the bottom of the axes that the x-axis
            %                    exponent (when shown) will fit on the figure
            %   hXTickLabel    - height of tick label including space between label and
            %                    axes (applies to all axes except bottom one)
            %   hXTickLabel1   - height of the bottom most axes tick label including space
            %                    between label and axes
            %   wYTickLabel    - width of tick labels on y-axis + extra space between
            %                    labels and axes + extra space between left edge of figure
            %                    and start of the text
            %   wRightSpace    - horizontal space between the right edge of the axes
            %                    and the edge of the figure.  It must be big enough to
            %                    accommodate the part of the last x tick label that hangs
            %                    passed the axes edge
            %   hTopSpace      - space between the top axes and the toolbar
            %   hAxesSpace     - vertical space between axes (not including titles)
            %   hBottomSpace   - vertical space between bottom of figure and first axes
            %
            
            if ~strcmp(axesGeom.tickLabelOpt, 'off')
                
                hTitle = 0; % No extra space needed.  It fits in the space allocated
                % for the y exponent.
                
                hYTickLabelExp = axExt(4) * expFactor;
                hTimeOffset    = max(uiExt(4) + 2, axExt(4) * expFactor);
                
                if strcmp(axesGeom.tickLabelOpt, 'OneTimeTick')
                    axesGeom.hXTickLabel = 0;
                else
                    axesGeom.hXTickLabel = axExt(4) + 2;
                end
                
                axesGeom.hXTickLabel1   = axExt(4) + 2;
                axesGeom.wYTickLabel    = tickLabelWidth + 3;
                axesGeom.wRightSpace    = axesGeom.wYTickLabel / 1.7;
                axesGeom.hTopSpace      = hYTickLabelExp;
                
                axesGeom.hAxesSpace = ...
                    max(hYTickLabelExp, hTitle) + ...
                    axesGeom.hXTickLabel        + ...
                    2;
                
                axesGeom.hBottomSpace = hTimeOffset + axesGeom.hXTickLabel1;
                
            else
                axesGeom.hXTickLabel    = 0;
                axesGeom.hXTickLabel1   = 0;
                axesGeom.wYTickLabel    = 0;
                axesGeom.wRightSpace    = 0;
                axesGeom.hTopSpace      = 0;
                axesGeom.hAxesSpace     = 0;
                axesGeom.hBottomSpace   = 0;
            end
        end % CreateAxesGeom
        
        % Function: GetYTickInfo =====================================================
        % Abstract:
        %
        %   Get YTickLabelMode, YTickLabels & YTicks for the specified axes.
        %
        %   The return argument is a structure with the following fields
        %     - Tick:          [] OR [values for enumerated data type]
        %     - TickMode:      'auto' OR 'manual'
        %     - TickLabel:     [] OR {strings for enumerated data type}
        %     - TickLabelMode: 'auto' OR 'manual'
        %
        function info = GetYTickInfo(scopeUserData, idx, changeNumberOfAxes)
            
            block = scopeUserData.block;
            tickLabelsOn = ~strcmp(get_block_param(block, 'TickLabels'), 'off');
            
            % Default values if YTickLabels are disabled
            info.TickLabelMode = 'manual';
            info.TickLabel     = [];
            info.TickMode      = 'auto';
            info.Tick          = [];
            
            if tickLabelsOn
                info.TickLabelMode = 'auto'; % by default
                
                % If number of axes is changing, just use the defaults
                if changeNumberOfAxes
                    return;
                end
                
                % If simulation is stopped or terminating, leave axes unchanged
                simStatus = get_block_param(bdroot(block), 'SimulationStatus');
                if (isequal(simStatus, 'stopped') || ...
                        isequal(simStatus, 'terminating'))
                    axis = scopeUserData.scopeAxes(idx);
                    info.TickLabelMode = get(axis, 'YTickLabelMode');
                    info.TickLabel     = get(axis, 'YTickLabel');
                    info.TickMode      = get(axis, 'YTickMode');
                    info.Tick          = get(axis, 'YTick');
                    return;
                end
                
                % Get name of data type for this axes if it is unique
                set_param(block, 'CurrentAxesIdx', idx);
                dataType = get_block_param(block, 'AxesCommonBaseType');
                
                % Early return if data type is mixed or model is not compiled
                if isempty(dataType)
                    return
                end
                
                % Special treatment for enumerated data types
                metaClass = Simulink.getMetaClassIfValidEnumDataType(dataType);
                if ~isempty(metaClass)
                    info.TickLabelMode = 'manual';
                    info.TickMode      = 'manual';
                    
                    [info.TickLabel, info.Tick] = ...
                        Simulink.getUniqueListOfEnumNamesAndValues(metaClass);
                end
            end
        end % GetYTickInfo
        
        
        % Function: SetYTickInfo =====================================================
        % Abstract:
        %   Utility function for applying yTickInfo to a set of axes.
        %
        function SetYTickInfo(hAxes, yTickInfo)
            
            % NOTE:
            %   We must set YTick before YTickMode because otherwise when
            %   you set YTick the YTickMode gets switched to 'manual'.
            %   Same goes for YTickLabel & YTickLabelMode.
            set(hAxes, ...
                'YTickLabel',     yTickInfo.TickLabel, ...
                'YTickLabelMode', yTickInfo.TickLabelMode, ...
                'YTick',          yTickInfo.Tick, ...
                'YTickMode',      yTickInfo.TickMode);
        end % SetYTickInfo
        
        
        % Function: FixPositionOfAxes(scopeUserData)
        % Abstract:
        %   Tweak horizontal position of axes to fit YTickLabels.
        %
        function FixPositionOfAxes(scopeUserData)
            
            axes = scopeUserData.scopeAxes;
            
            % EARLY RETURN if no tick labels being displayed
            tickLabelsOff = strcmp(get_block_param(scopeUserData.block, 'TickLabels'), 'off');
            if tickLabelsOff
                return
            end
            
            % Otherwise change x-position (and width) of axes to fit YTickLabels.
            pos      = get(axes, 'Position');
            outerPos = get(axes, 'OuterPosition');
            
            if iscell(pos)
                pos      = cell2mat(pos);
                outerPos = cell2mat(outerPos);
            end
            
            if all(strcmp(get(axes, 'YTickLabelMode'), 'auto'))
                % All axes using "auto" tick labels
                % ==> Return to nominal axes positions
                axExt = Simulink.scopes.Util.AxesExtent(scopeUserData);
                left  = axExt(3);
                width = pos(1,1)+pos(1,3)-left;
            else
                % Resize axes to force outerLeft edge inside figure
                outerLeft = outerPos(:,1);
                farLeft   = min(outerLeft)-5;
                left  = pos(1,1)-farLeft;
                width = pos(1,3)+farLeft;
                
                % Width must be positive
                if width <= 0
                    left  = left+width;
                    width = 1;
                end
            end
            
            pos(:,1) = left;
            pos(:,3) = width;
            
            for idx = 1:length(axes)
                set(axes(idx), 'Position', pos(idx, :));
            end
        end % FixPositionOfAxes
        
        
        % Function: ComputeAxesInfo =================================================
        % Abstract:
        %
        % Compute the axes information based on the current window configuration.
        % The return argument is an array of structures (1xnAxes) with fields:
        %   - Position:       [xLeft, yBottom, width, height]
        %   - XTickLabelMode: 'auto' OR 'manual'
        %   - YTickInfo:
        %     - Tick:          [] OR [values for enumerated data type]
        %     - TickMode:      'auto' OR 'manual'
        %     - TickLabel:     [] OR {strings for enumerated data type}
        %     - TickLabelMode: 'auto' OR 'manual'
        %
        function axesInfo = ComputeAxesInfo(scopeFig, scopeUserData, axesGeom, nAxes)
            
            posScope       = get(scopeFig, 'Position');
            hScope         = posScope(4);
            wScope         = posScope(3);
            tickLabelModes = {'manual', 'auto'};
            changeNumberOfAxes = (nAxes ~= length(scopeUserData.scopeAxes));
            
            %
            % Determine the nominal horizontal dimensions for the axes (left & width).
            % NOTE:
            % - All axes have the same horizontal dimensions.
            % - This position may get tweaked if the YTickLabels don't fit onto the scope.
            %
            left  = axesGeom.wYTickLabel;
            right = wScope - axesGeom.wRightSpace;
            wAxes = max(right - left, 1); % keep dims > 1
            
            %
            % Determine the axes height.  Note that all axes are the same height.
            %
            hAxesSpaces = axesGeom.hAxesSpace  * (nAxes - 1);
            
            hAllAxes = ...
                hScope                  - ...
                hAxesSpaces             - ...
                axesGeom.hTopSpace      - ...
                axesGeom.hBottomSpace;
            
            hAxes = max((hAllAxes / nAxes), 1); % keep dims > 1
            
            %
            % ... set up axes positions, ticks & labels
            %
            bottom = axesGeom.hBottomSpace;
            axesInfo = struct('Position', cell(1,nAxes)); % Preallocate
            if strcmp(axesGeom.tickLabelOpt, 'off')
                % If no tick labels displayed the axes fill the figure but set XTickLabelMode
                % to 'auto' so that signal viewer scope can display "inside" tick labels
                xTickLabelMode = 'auto';
            else
                xTickLabelMode = tickLabelModes{(axesGeom.hXTickLabel ~= 0)+1};
            end
            
            for i=nAxes:-1:1,
                axesInfo(i).Position       = [left bottom wAxes hAxes];
                axesInfo(i).XTickLabelMode = xTickLabelMode;
                axesInfo(i).YTickInfo      = Simulink.scopes.Util.GetYTickInfo(scopeUserData, i, changeNumberOfAxes);
                
                top    = bottom + hAxes;
                bottom = top + axesGeom.hAxesSpace;
            end
            
            %
            % ... handle the bottom-most axes specially, as it may be the only one
            %     with tick labels on the x-axis
            %
            if strcmp(axesGeom.tickLabelOpt, 'off')
                % If no tick labels displayed the axes fill the figure but set XTickLabelMode
                % to 'auto' so that signal viewer scope can display "inside" tick labels
                axesInfo(nAxes).XTickLabelMode = 'auto';
            else
                axesInfo(nAxes).XTickLabelMode = tickLabelModes{(axesGeom.hXTickLabel1 ~= 0)+1};
            end
        end %ComputeAxesInfo
        
        % Function: ComputeSimulationTimeSpan =======================================
        % Abstract:
        %
        % Compute the simulation time span - used for resolving 'auto' time range.
        %
        % There are 2 cases:
        %   1) Simulation is running (or initialized):
        %      The actual time span (tFinal - tStart) will be returned.  Note that this
        %      routine will not be aware of any changes to start or stop time that are
        %      made while the simulation is running.
        %
        %   2) Simulation not running:
        %      Try to evaluate tStart and tFinal in the base workspace.  If they don't
        %      exist, return 10.
        %
        function simTimeSpan = ...
                ComputeSimulationTimeSpan(block, block_diagram, simStatus)
            
            strStartTime   = get_block_param(block_diagram, 'StartTime');
            strStopTime    = get_block_param(block_diagram, 'StopTime');
            defSimTimeSpan = 10;
            simTimeSpan    = -1;
            
            if ~strcmp(simStatus, 'stopped')
                simTimeSpan = get_block_param(block, 'SimTimeSpan');
                if strcmp(simStatus,'initializing') && simTimeSpan == 0
                    simTimeSpan = defSimTimeSpan;
                end
                if strcmp(simStatus,'updating') && simTimeSpan == 0
                    simTimeSpan = defSimTimeSpan;
                end
            else
                startTime = evalin('base', strStartTime, 'NaN');
                stopTime  = evalin('base', strStopTime,  'NaN');
                
                %
                % Try to calculate the simTimeSpan, assuming valid start/stop times.
                %
                try
                    if isnan(startTime) || isnan(stopTime) || stopTime == Inf ||...
                            stopTime - startTime == 0,
                        simTimeSpan = defSimTimeSpan;
                    else
                        simTimeSpan = stopTime - startTime;
                    end
                end
                
                %
                % Verify that we wound up with "nice" positive, scalar timespan.
                % Note, there are bizarre cases such as g292455 where users can
                % put strings into the stoptime field of the sim params dialog
                % box.  The strings can accidentally or otherwise resolve to Matlab
                % functions that return crazy things such as transfer function
                % objects which we don't really expect here.  The 'try' above and
                % below guard against these conditions.
                %
                try
                    if ~isnumeric(simTimeSpan) || (simTimeSpan <= 0) ||...
                            ~isreal(simTimeSpan) || ~isscalar(simTimeSpan),
                        simTimeSpan = defSimTimeSpan;
                    end
                catch
                    simTimeSpan = defSimTimeSpan;
                end
            end
        end %ComputeSimulationTimeSpan
        
        % Function: ComputeAxesLimits ===============================================
        % Abstract:
        %
        % Calculate the axes limits based on stored values.
        %
        % tLim   - the limits of the axes [0 tRange]
        % offset - the corresponding offset (add to tLim to get actual)
        % yLim   - A matrix of y-limits is returned where each row corresponds to an
        %          axis.  Row 1 is the top-most axes.
        
        function [tLim, yLim, offset] = ComputeAxesLimits(~, scopeUserData)
            
            block         = scopeUserData.block;
            block_diagram = scopeUserData.block_diagram;
            simStatus     = get_block_param(block_diagram, 'SimulationStatus');
            
            %
            % Build "eval-able" strings for the ymin and ymax vectors.  They are
            % stored in the models as: ymin1~ymin2~ymin3....
            %
            strYMin                 = get_block_param(block, 'YMin');
            strYMin(strYMin == '~') = ',';
            strYMin                 = ['[' strYMin ']'];
            
            strYMax                 = get_block_param(block, 'YMax');
            strYMax(strYMax == '~') = ',';
            strYMax                 = ['[' strYMax ']'];
            
            strTRange = Simulink.scopes.Util.GetTimeRange(block);
            
            %
            % Calculate Y-Limits.  The strings are stored in the mdl file in the form:
            %   "ymax1 ymax2 ymax3 ... ymaxN"
            %   "ymin1 ymin2 ymin3 ... yminN"
            %
            yMin = (eval(strYMin, 'DAStudio.error(''Simulink:blocks:UnexpectedString4YMin'')'))';
            yMax = (eval(strYMax, 'DAStudio.error(''Simulink:blocks:UnexpectedString4YMax'')'))';
            
            yLim = [yMin yMax];
            
            eqLimits = find(yLim(:,1) == yLim(:,2));
            for rowIdx = eqLimits,
                val   = yLim(rowIdx,1);
                delta = 0.05 * abs(val);
                yLim(rowIdx,:) = [val - delta, val + delta];
            end
            
            %
            % Calculate T-Limits.
            %
            if strcmp(strTRange, 'auto')
                tRange = Simulink.scopes.Util.ComputeSimulationTimeSpan(block, block_diagram, simStatus);
                if isinf(tRange)
                    tRange = 10.0;
                end
            else
                tRange = sscanf(strTRange, '%lf');
            end
            
            offset = get_block_param(block, 'offset');
            tLim   = [0 tRange];
        end %ComputeAxesLimits
        
        % Function: SetBlockYLims ===================================================
        % Abstract:
        %
        % Given a matrix of yLims (1 row per axes) build the appropriate strings for
        % the YMin and YMax properties of the blocks.  The strings are ~ separated
        % lists of the form:
        %   yminAx1~yminAx2~yMinax3, ...
        
        function SetBlockYLims(block, yLim)
            
            % Don't issue set_param if the parameter value doesn't change
            % This is necessary because the string representation of exponential numbers
            % is different on the various platforms.  For example, UNIX: 1.0e-15, PC: 1.0e-015
            % Since the string size changes, the models were getting dirtied on model load
            try
                strYMin                 = get_block_param(block, 'YMin');
                strYMin(strYMin == '~') = ',';
                strYMin                 = ['[' strYMin ']'];
                oldYMin = eval(strYMin);
                
                strYMax                 = get_block_param(block, 'YMax');
                strYMax(strYMax == '~') = ',';
                strYMax                 = ['[' strYMax ']'];
                oldYMax = eval(strYMax);
                changed = ~isequal(yLim(:,1), oldYMin') || ~isequal(yLim(:,2), oldYMax');
            catch
                changed = 1;
            end
            
            if changed
                yMinStr = sprintf('%g~', yLim(:,1));  yMinStr(end) = [];
                yMaxStr = sprintf('%g~', yLim(:,2));  yMaxStr(end) = [];
                set_param(block, 'YMin', yMinStr, 'YMax', yMaxStr);
            end
        end % SetBlockYLims
        % Function: TitleCell2Struct ==================================================
        % Abstract:
        %
        % Convert a cell array of title strings into a struct of the form:
        % struct.axes1 = 'title1';
        % struct.axes2 = 'title2';
        % ...
        
        function outStruct = TitleCell2Struct(titles)
            
            nTitles    = length(titles);
            fieldNames = cell(1, nTitles);
            
            for i=1:nTitles,
                fieldNames{i} = ['axes' sprintf('%d',i)];
            end
            
            outStruct = cell2struct(titles, fieldNames,1);
        end % TitleCell2Struct
        
        % Function: UpdateTitles ====================================================
        % Abstract:
        %
        % Update the titles on all the axes.
        
        function UpdateTitles(scopeUserData)
            
            block = scopeUserData.block;
            DefaultAxesTitlesString = get_block_param(block,'DefaultAxesTitlesString');
            
            modified  = 0;
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            titles    = get_block_param(block, 'AxesTitles');
            
            %
            % Convert titles to cell array.
            %
            
            titles  = Simulink.scopes.Util.struct2cell(titles);
            nTitles = length(titles);
            changed = 0;
            
            %
            % Update the titles stored by the block - if needed.
            %
            if (nTitles > nAxes)
                % remove the extras
                titles(nAxes+1:end) = [];
                changed = 1;
            end
            
            if (nTitles < nAxes)
                % pad with default title
                [titles{end+1:nAxes,1}] = deal(DefaultAxesTitlesString);
                changed = 1;
            end
     %       if changed,
     %           % update the block
     %           set_param(block, 'AxesTitles', TitleCell2Struct(titles));
     %       end
            
            %
            % Update the titles on the scope figure.
            %
            fontSize     = scopeUserData.axesFontSize;
            fontName     = scopeUserData.axesFontName;
            
            if strcmp(get_block_param(block, 'Ticklabels'), 'off')
                visible = 'off';
            else
                visible = 'on';
            end
            
            titles = Simulink.scopes.Util.struct2cell(get_block_param(block,'ResolvedAxesTitles'));
            for i=1:nAxes,
                ax           = scopeAxes(i);
                hTitle       = get(ax, 'Title');
                currentTitle = get(hTitle, 'String');
                if strcmp(get_block_param(block, 'Floating'), 'on')
                    newTitle = '';
                else
                    newTitle = titles{i};
                end
                
                %
                % Update the axes's title - if needed
                %
                
                % ... make sure that both use the same form of empty to
                %     work around bug (i.e., make sure that both are
                %     0x0)
                if isempty(newTitle), newTitle = ''; end
                if isempty(currentTitle), currentTitle = ''; end
                
                if ~strcmp(newTitle, currentTitle)
                    modified = 1;
                    set(hTitle, ...
                        'Interpreter',  'none', ...
                        'String',       newTitle,...
                        'FontName',     fontName, ...
                        'FontSize',     fontSize, ...
                        'Visible',      visible, ...
                        'Color',        get(ax, 'XColor'));
                else
                    % make sure that the visibility is correct
                    set(hTitle, 'Visible', visible);
                end
            end
            
            if (modified)
                % figure has re-rendered - invalidate the blit buffer
                get_block_param(block, 'InvalidateBlitBuffer');
            end
        end % UpdateTitles
        
        % Function: UpdateDefLimits =================================================
        % Abstract:
        %
        % Update all defYlim and defTLims.  These are the cached values of the axes
        % limits used to determine if the 'save current settings' menu items and
        % toolbar buttons should be enabled.
        
        function UpdateDefLimits(scopeUserData)
            
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            
            yLims = get(scopeAxes, 'YLim');
            if iscell(yLims)
                yLims = cat(1, yLims{:});
            end
            
            xLim = get(scopeAxes(1), 'XLim');
            
            for i=1:nAxes,
                ax           = scopeAxes(i);
                axesUserData = get(ax, 'UserData');
                
                axesUserData.defXLim = xLim;
                axesUserData.defYLim = yLims(i,:);
                
                set(ax, 'UserData', axesUserData);
            end
            
        end %UpdateDefLimits
        
        % Function: AxesColors ======================================================
        % Abstract:
        %
        % Determine color attributes of scope axes.
        function [axesColor, ticColor, axesColorOrder] = AxesColors(thisComputer)
            
            %
            % Set up color info.
            %
            switch(thisComputer)
                
                case 'PCWIN',
                    axesColor = 'k';
                    ticColor  = 'w';
                    
                    axesColorOrder = [
                        1 1 0
                        1 0 1
                        0 1 1
                        1 0 0
                        0 1 0
                        0 0 1];
                    
                case 'MAC2',
                    axesColor      = get(0, 'DefaultAxesColor');
                    ticColor       = get(0, 'DefaultAxesXColor');
                    axesColorOrder = get(0, 'DefaultAxesColorOrder');
                    
                otherwise,  % X
                    axesColor = 'k';
                    ticColor  = 'w';
                    
                    axesColorOrder = [
                        1 1 0
                        1 0 1
                        0 1 1
                        1 0 0
                        0 1 0
                        0 0 1];
            end
        end % AxesColors
        
        % Function: UpdateAxesConfig ================================================
        % Abstract:
        %   Create the scope axes and time offset label - if needed.  ScopeUserData is
        %   always modified.  Make sure that the number of input ports is set to the
        %   desired number before calling this function.
        
        function [modified, scopeUserData] = UpdateAxesConfig(...
                scopeFig, scopeUserData)
            
            block        = scopeUserData.block;
            scopeAxes    = scopeUserData.scopeAxes;
            nAxes        = length(scopeAxes);
            scopeHiLite  = scopeUserData.scopeHiLite;
            floating     = slprivate('onoff',get_block_param(block,'Floating'));
            modelBased   = Simulink.scopes.Util.IsModelBased(block);
            wireless     = slprivate('onoff',get_block_param(block,'Wireless'));
            modified     = 0;
            axesGeom     = Simulink.scopes.Util.CreateAxesGeom(scopeFig, scopeUserData);
            [tLim, yLim] = Simulink.scopes.Util.ComputeAxesLimits(scopeFig, scopeUserData);
            
            if wireless,
                nAxesNeeded = eval(get_block_param(block,'NumInputPorts'));
                nAxesNeeded = nAxesNeeded(1); % number requested by user
            else
                nAxesNeeded = get_block_param(block, 'ports');
                nAxesNeeded = nAxesNeeded(1); %number of input ports
            end
            
            %
            % Compute the positions & other information for the axes.
            % The upper most axes is the axis with index 1.
            %
            axesInfo = Simulink.scopes.Util.ComputeAxesInfo(scopeFig, scopeUserData, axesGeom, nAxesNeeded);
            
            if (nAxesNeeded ~= nAxes)
                
                % start from scratch by deleting the axes and their prop dialogs (if opened)
                for i=1:nAxes,
                    axUserData = get(scopeAxes(i), 'UserData');
                    if ishandle(axUserData.propDlg)
                        delete(axUserData.propDlg);
                    end
                    Simulink.scopes.Util.DeleteAxesHiLite(scopeAxes(i));
                end
                
                delete(scopeAxes);
                modified = 1;
                
                [axesColor, ticColor, axesColorOrder] = ...
                    Simulink.scopes.Util.AxesColors(scopeUserData.thisComputer);
                
                %
                % Create the axes.
                %
                scopeUserData.scopeAxes      = 1:nAxesNeeded; % alloc
                scopeUserData.scopeHiLite    = INVALID_HANDLE*ones(1,nAxesNeeded); % alloc
                axUserData.propDlg           = INVALID_HANDLE;
                axUserData.defXLim           = tLim;
                axUserData.defYLim           = [];
                axUserData.idx               = [];
                axUserData.signals           = [];
                
                %
                % ...If there are more axes than stored yLim settings, than pad the yLim
                %    matrix with the proper number of default axes limits.  If the number has
                %    decreased remove the extra entries.
                %
                numToAdd = nAxesNeeded - size(yLim,1);
                if numToAdd > 0,
                    defLims = [-5 5];
                    newLims = defLims(ones(1,numToAdd), :);
                    yLim = [yLim; newLims];
                end
                
                if numToAdd < 0,
                    yLim = yLim(1:nAxesNeeded, :);
                end
                
                %
                % ...create the axes.
                %
                for i=1:nAxesNeeded,
                    axUserData.idx     = i;
                    axUserData.defYLim = yLim(i,:);
                    
                     axesTmp = axes(...
                        'Parent',           scopeFig,...
                        'Units',            'pixel', ...
                        'Position',         axesInfo(i).Position, ...
                        'XLim',             tLim, ...
                        'YLim',             yLim(i,:), ...
                        'XGrid',            'on', ...
                        'YGrid',            'on', ...
                        'Color',            axesColor, ...
                        'ColorOrder',       axesColorOrder, ...
                        'XColor',           ticColor, ...
                        'YColor',           ticColor, ...
                        'XTickLabelMode',   axesInfo(i).XTickLabelMode, ...
                        'XTickMode',        'auto', ...
                        'Box',              'on', ...
                        'FontSize',         scopeUserData.axesFontSize, ...
                        'FontName',         scopeUserData.axesFontName, ...
						'tag',				'ScopeAxes', ...
                        'Interruptible',    'off', ...
                        'UserData',         axUserData, ...
                        'UIContextMenu',    scopeUserData.axesContextMenu.root);
					axesTmp = Simulink.scopes.Util.hg1SetAxes(axesTmp);
                    scopeUserData.scopeAxes(i) = axesTmp;
                    if wireless
                        scopeUserData.scopeHiLite(i) = Simulink.scopes.Util.CreateAxesHiLite(scopeFig, ...
                            scopeUserData.scopeAxes(i), ...
                            tLim, yLim(i,:));
                        modified = 1;
                    end
                end
                
                %
                % Update the SelectedSignals to keep it in sync with
                % the scopeAxes data.  Then update the SelectedPortHandles
                % to keep them in sync.
                %
                Simulink.scopes.Util.UpdateSelectionDataNumAxes(block,nAxesNeeded);

                
                nAxes = nAxesNeeded;
                
                %
                % By default, the uppermost axes (#1) is selected and
                % NOT activated upon opening the first wireless scope.
                %
                if wireless
                    selAxesIdx = get_block_param(block,'selectedAxesIdx');
                    if selAxesIdx < 1 || selAxesIdx > nAxes
                        selAxesIdx = 1;
                        set_param(block, 'SelectedAxesIdx', selAxesIdx);
                        % Note: The HiLite is handled below
                    end
                    
                    set(scopeFig, 'CurrentAxes', scopeUserData.scopeAxes(selAxesIdx));
                    set_param(block, 'CurrentAxesIdx', selAxesIdx);
                    Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
                end
                
                %
                % Update the blocks YMin and YMax so that the strings are of the
                % proper length  (i.e., one element per axis)
                %
                Simulink.scopes.Util.SetBlockYLims(block, yLim);
                
            else
                
                if ~strcmp(scopeUserData.tickLabelOpt, axesGeom.tickLabelOpt)
                    % force a redraw in the current configuration
                    [modified, scopeUserData] = Simulink.scopes.Util.ResizeAxes( ...
                        scopeFig, scopeUserData, axesGeom);
                end
                
                %
                % Update time ranges - if needed
                %
                blockTimeRange = tLim(2);
                axesTimeRange  = get(scopeAxes(1), 'XLim');
                axesTimeRange  = axesTimeRange(2) - axesTimeRange(1);
                
                if (blockTimeRange ~= axesTimeRange)
                    scopeAxes = scopeUserData.scopeAxes;
                    nAxes     = length(scopeAxes);
                    for i=1:nAxes,
                        ax           = scopeAxes(i);
                        axesUserData = get(ax, 'UserData');
                        
                        set(ax, 'XLim', tLim);
                        axesUserData.defXLim = tLim;
                        set(ax, 'UserData', axesUserData);
                        
                        %
                        % Update wireless scope highlighting positions
                        % if they exist.
                        %
                        if ishandle(scopeUserData.scopeHiLite(i))
                            Simulink.scopes.Util.HiLiteResize(scopeUserData,i,tLim,yLim(i,:));
                        else
                            scopeUserData.scopeHiLite(i) = INVALID_HANDLE;
                            Simulink.scopes.Util.DeleteAxesHiLite(ax);
                        end
                    end
                end
            end
            
            % Always set up the YTick attributes for the axes
            for i=1:nAxesNeeded,
                Simulink.scopes.Util.SetYTickInfo(scopeUserData.scopeAxes(i), axesInfo(i).YTickInfo);
            end
            Simulink.scopes.Util.FixPositionOfAxes(scopeUserData);
            
            % figure has re-rendered - invalidate the blit buffer
            get_block_param(block, 'InvalidateBlitBuffer');
            
            %
            % Update status of the tick offset controls.
            %
            if ~strcmp(axesGeom.tickLabelOpt, 'off')
                if scopeUserData.timeOffsetLabel == INVALID_HANDLE,
                    scopeUserData = Simulink.scopes.Util.CreateTimeOffsetCtrls(scopeFig, scopeUserData);
                    set(scopeUserData.timeOffset, 'String', '0');
                else
                    set([scopeUserData.timeOffsetLabel, scopeUserData.timeOffset], ...
                        'Visible',  'on');
                end
            else
                if scopeUserData.timeOffsetLabel ~= INVALID_HANDLE,
                    set([scopeUserData.timeOffsetLabel, scopeUserData.timeOffset], ...
                        'Visible',  'off');
                end
            end
            
            %
            % Update the status of floating scope highlighting/focus rectangles
            %
            if wireless
                for i=1:nAxes,
                    % create blue focus rectangle(s) and callback(s)
                    % if they don't exist, reset axes to nominal.
                    if ~ishandle(scopeUserData.scopeHiLite(i))
                        set(scopeUserData.scopeAxes(i), ...
                            'XLim',       tLim, ...
                            'YLim',       yLim(i,:) ...
                            );
                        
                        scopeUserData.scopeHiLite(i) = Simulink.scopes.Util.CreateAxesHiLite( ...
                            scopeFig, ...
                            scopeUserData.scopeAxes(i), ...
                            tLim, yLim(i,:));
                        modified = 1;
                    end
                end
                
                selAxesIdx = get_block_param(block,'SelectedAxesIdx');
                
                if floating
                    % Mouse selection enabled only for floating scope.
                    set(scopeFig, 'ButtonDownFcn', 'simscope(''LockDownAxes'')');
                else
                    % HiLite is on when not running for modelBased scope.
                    if Simulink.scopes.Util.IsSimActive(scopeUserData.block_diagram)
                        Simulink.scopes.Util.HiLiteOff(scopeUserData,selAxesIdx);
                    else
                        Simulink.scopes.Util.HiLiteOn(scopeUserData,selAxesIdx);
                    end
                end
                
                
                %
                % Set selected axes focus if LockDown is off
                %
                if strcmp(get_block_param(block, 'LockDownAxes'), 'off')
                    if floating
                        % HiLite is on when LockDown is off for floating scope.
                        Simulink.scopes.Util.HiLiteOn(scopeUserData,selAxesIdx);
                    end
                    oldScope = get_param(scopeUserData.block_diagram,'FloatingScope');
                    if strcmp(oldScope,'')
                        formattedBlockPath = getfullname(block);
                        set_param(scopeUserData.block_diagram, 'FloatingScope', ...
                            formattedBlockPath);
                    end
                end
            else
                for i=1:nAxes,
                    % delete the highlighting rectangle and references to it.
                    if ishandle(scopeUserData.scopeHiLite(i))
                        scopeUserData.scopeHiLite(i) = INVALID_HANDLE;
                        modified = 1;
                    end
                    Simulink.scopes.Util.DeleteAxesHiLite(scopeUserData.scopeAxes(i));
                    
                    % remove any buttondown callback from this axes
                    set(scopeUserData.scopeAxes(i), 'ButtonDownFcn', '');
                end
                % remove any buttondown callback from the figure background
                set(scopeFig, 'ButtonDownFcn', '');
            end
            
            %
            % Update context menu and support Signal selector on java supported platforms
            %
            if wireless && usejava('MWT')
                set(scopeUserData.axesContextMenu.select,'Visible','on', 'Enable', 'on');
            else
                set(scopeUserData.axesContextMenu.select,'Visible','off');
            end
            
            %
            % Update titles
            %
            Simulink.scopes.Util.UpdateTitles(scopeUserData);
            
            %
            % Create/Update the Scope Zoom Data Structure
            %
            scopeUserData.zoomUserStruct = ...
                Simulink.scopes.Util.CreateZoomDataStructure(scopeUserData,scopeFig,nAxesNeeded);
            
            %
            % update the zoom button state and enabledness
            %
            scopebar(scopeFig, 'ZoomModeSwitch', get_block_param(scopeUserData.block,'ZoomMode'));
            Simulink.scopes.Util.DisableZoom(scopeFig, scopeUserData);
            
        end % function UpdateAxesConfig
            
        
        
        % Function: CreateZoomDataStructure =========================================
        % Abstract:
        %    Creates the scope zoom data structure and attaches it to the scope
        %    user data.
        %
        function zoomUserStruct = ...
                CreateZoomDataStructure(scopeUserData, scopeFig, nNewAxes)
            
            hAx = scopeUserData.scopeAxes;
            
            %
            % Total Number of Axis in the scope
            %
            zoomUserStruct.AXnum = nNewAxes;
            
            %
            % Axis stack - initialize to 20 levels.
            %  Each row contains 4 #'s:  [xmin xmax ymin ymax]
            %
            zoomUserStruct.stack = zeros(nNewAxes, 20, 4);
            
            %
            % Index of current top of stack.
            %
            zoomUserStruct.topOfStack = 0;
            
            %
            % Handles to lines for rbbox.
            %
            zoomUserStruct.hLines = zeros(4, 1) - 1;
            
            %
            % Keep a copy of the original axis settings.
            %  This way we'll have access to them, even
            %  if the stack is empty.
            %
            zoomUserStruct.originalLimits = zeros(nNewAxes, 4);
            for i=1:nNewAxes,
                zoomUserStruct.originalLimits(i,:) = ...
                    [get(hAx(i), 'XLim'), get(hAx(i), 'YLim')];
            end
            
            %
            % Create fields for previous selection type.
            %
            zoomUserStruct.oldSelectionType = 'blah';
        end %CreateZoomDataStructure
        
        % Function: Initialize ======================================================
        % Abstract:
        %    Create the scope figure window, toolbar and axes.
        
        function [scopeFig, scopeUserData] = Initialize(block)
            
            blockName      = get_block_param(block, 'Name');
            block          = get_block_param(block, 'Handle');
            block_diagram  = bdroot(block);
            simStatus      = get_block_param(block_diagram, 'SimulationStatus');
            uiFontName     = get(0, 'FactoryUicontrolFontName');
            uiFontSize     = get(0, 'FactoryUicontrolFontSize');
            axesFontName   = uiFontName;
            axesFontSize   = uiFontSize;
            scopePosition  = slprivate('rectconv',get_block_param(block, 'Location'), 'hg');
            wireless       = slprivate('onoff',get_block_param(block,'Wireless'));
            modelBased     = Simulink.scopes.Util.IsModelBased(block);
            thisComputer   = computer;
            figColor       = [0.5 0.5 0.5];
            
            if strcmp(thisComputer, 'MAC2')
                figColor = get(0, 'DefaultFigureColor');
            end
            
            if wireless
                LockDownCallbackStr = 'simscope(''LockDownAxes'')';
            else
                LockDownCallbackStr = '';
            end
            
            %
            % Initialize some figure userdata fields.
            %
            scopeUserData.block            = block;
            scopeUserData.block_diagram    = block_diagram;
            scopeUserData.thisComputer     = thisComputer;
            scopeUserData.toolGeom         = [];
            scopeUserData.scopePropDlg     = INVALID_HANDLE;
            scopeUserData.dialogGeom       = [];
            scopeUserData.graphical        = [];
            scopeUserData.timeOffsetLabel  = INVALID_HANDLE;
            scopeUserData.timeOffset       = INVALID_HANDLE;
            scopeUserData.scopeAxes        = [];
            scopeUserData.scopeHiLite      = [];
            scopeUserData.tickLabelOpt     = '';
            
            %
            % If this is a Model-based scope (aka 'Signal Viewer'), remove the
            % prefix string from the block name and add something to the title
            % to differentiate it from a regular scope of the same name.
            %
            if modelBased
                windowTitle = viewertitle(block, false);
            else
                floating  = slprivate('onoff',get_block_param(block,'Floating'));
                if floating,
                    depSuffix = '';
                else,
                    %depSuffix = ' (Deprecated)';
                    depSuffix = '';
                end
                
                windowTitle = [blockName depSuffix];
            end
            
            
            %
            % Create the figure.
            %
            scopeFig = figure(...
                'MenuBar',                          'none', ...
                'Units',                            'pixels', ...
                'Name',                             windowTitle, ...
                'Tag',                              'SIMULINK_SIMSCOPE_FIGURE',...
                'Position',                         slprivate('figpos',scopePosition), ...
                'NextPlot',                         'new', ...   % g554783 Prevent subplot from hijacking scope
                'NumberTitle',                      'off', ...
                'Visible',                          'off', ...
                'Renderer',                         'zbuffer', ...
                'ButtonDownFcn',                    LockDownCallbackStr, ...
                'DefaultUicontrolFontSize',         uiFontSize, ...
                'DefaultUicontrolFontName',         uiFontName, ...
                'DefaultUicontrolHorizontalAlign',  'left', ...
                'DefaultAxesUnits',                 'pixels', ...
                'ColorMap',                         [], ...
                'Color',                            figColor, ...
                'IntegerHandle',                    'off');
            
            Simulink.scopes.Util.hg1SetFigure(scopeFig);
            
            b = hggetbehavior(scopeFig,'PlotTools');
            b.ActivatePlotEditOnOpen = false;
            
            %
            % Create the context menu used by the axes.
            %
            hRoot = uicontextmenu( ...
                'Parent',          scopeFig, ...
				'tag', 'ScopeContextMenu', ...
                'Callback',        'simscope(''AxesContextMenu'',''Adjust'')');
            
            scopeUserData.axesContextMenu.root = hRoot;
            
            scopeUserData.axesContextMenu.zoomout = uimenu(hRoot, ...
                'Label',        Simulink.scopes.Util.lclMessage('ScopeZoomOut'), ...
                'Enable',       'off',...
				'tag', 'ScopeZoomOut', ...
                'Callback',     'simscope(''AxesContextMenu'',''ZoomOut'')');
            
            scopeUserData.axesContextMenu.find = uimenu(hRoot, ...
                'Label',        Simulink.scopes.Util.lclMessage('ScopeAutoscale'), ...
				'tag', 'ScopeAutoscale', ...
                'Callback',     'simscope(''AxesContextMenu'',''Find'')');
            
            scopeUserData.axesContextMenu.sync = uimenu(hRoot, ...
                'Label',        Simulink.scopes.Util.lclMessage('ScopeSaveAxesSettings'), ...
				'tag', 'ScopeSaveAxesSettings', ...
                'Enable',       'off', ...
                'Callback',     'simscope(''AxesContextMenu'',''Sync'')');
            
            scopeUserData.axesContextMenu.select = uimenu(hRoot, ...
                'Label',        Simulink.scopes.Util.lclMessage('ScopeSignalSelection'), ...
				'tag', 'ScopeSignalSelection', ...
                'Enable',       'on', ...
                'Callback',     'simscope(''AxesContextMenu'',''Select'')');
            
            scopeUserData.axesContextMenu.properties = uimenu(hRoot, ...
                'Label',        Simulink.scopes.Util.lclMessage('ScopeAxesProperties'), ...
				'tag', 'ScopeAxesProperties', ...
                'Callback',     'simscope(''AxesContextMenu'',''Properties'')', ...
                'Separator',    'on');
            
            %
            % Create a hidden uicontrol for text sizing & define fonts.
            %
            scopeUserData.textExtent = uicontrol(...
                'Style',          'text', ...
                'Visible',        'off' ...
                );
            
            scopeUserData.uiFontName    = uiFontName;
            scopeUserData.uiFontSize    = uiFontSize;
            scopeUserData.axesFontName  = axesFontName;
            scopeUserData.axesFontSize  = axesFontSize;
            
            %
            % Create the scope axes and the toolbar.            %
            scopeUserData = scopebar(scopeFig, 'Create', scopeUserData);
            [~, scopeUserData] = Simulink.scopes.Util.UpdateAxesConfig(scopeFig, scopeUserData);
            
            set(scopeFig, 'Visible', 'on'); % the scope is ready for display
            
            %
            % Setup the lineStyle order.
            %
            scopeUserData.lineStyleOrder = {'-','--',':','-.'};
            %
            % Set the updated user data & finish off figure properties.
            %
            set(scopeFig,...
                'UserData',                 scopeUserData, ...
                'CloseRequestFcn',          'simscope CloseReq', ...
                'DeleteFcn',                'simscope DeleteFcn', ...
                'ResizeFcn',                'simscope Resize', ...
                'HandleVisibility',         'callback' ...          % xxx try to make this off
                );
            
            %                'DeleteFcn',                'simscope DeleteFcn', ...
            %
            % Now that the user data is set, initialize the toolbar zoom buttons
            %
            
            scopebar(scopeFig, 'ZoomModeSwitch', get_block_param(scopeUserData.block,'ZoomMode'));
            
            %
            % Let the model know whats going on out here.
            %
            set_param(block, 'Figure', double(scopeFig));

        end % Initialize
        
        
        % Function: GetAllLineHandles ===============================================
        % Abstract:
        %    Get handles to all lines on all axes.
        
        function allLines = GetAllLineHandles(block,userData)
            
            scopeAxes = userData.scopeAxes;
            nAxes = length(scopeAxes);
            
            allLines = [];
            for i=1:nAxes,
                [valid, hLines] = Simulink.scopes.Util.GetAxesLines(block,scopeAxes,i);
                if valid
                    allLines = [allLines hLines];
                end
            end
        end % GetAllLineHandles
        
        % Function: ShiftNPlotAllAxes ===============================================
        % Abstract:
        %
        % Call the Simulink.scopes.Util.ShiftNPlot function for all axes and clean up any "lit"
        % pixels that have no associated data.
        %
        % endLiveTrace: Set to 1 if the scope is in the process of going from live
        %               trace to data analysis mode (e.g., end of the simulation or
        %               end of a data logging event in external mode).
        
        function ShiftNPlotAllAxes( ...
                scopeUserData, scopeLineData, endLiveTrace)
            
            if isempty(scopeLineData), return, end
            
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            
            for i=1:nAxes,
                Simulink.scopes.Util.ShiftNPlot(scopeUserData, scopeLineData, i);
            end
            
            %
            % Get rid of "lit" pixels that have no associated data (if needed).
            %
            if endLiveTrace,
                block        = scopeUserData.block;
                offset       = get_block_param(block, 'offset');
                axIdx        = 1;
                ax           = scopeAxes(axIdx);
                xLim         = get(ax, 'XLim');

                [validLines,hLines] = Simulink.scopes.Util.GetAxesLines(block,scopeAxes, axIdx);

                if validLines
                    
                    xData = get(hLines(1), 'XData');
                    
                    if xData(1) > xLim(1)
                        %
                        % Clear background
                        %
                        get_block_param(block, 'BlitBackground');
                        
                        %
                        % Force lines to redraw with their current data.
                        %
                        allLines = Simulink.scopes.Util.GetAllLineHandles(block,scopeUserData);
                        set(allLines, 'Visible', 'off', 'Visible', 'on');
                    end
                end
            end
            
        end % ShiftNPlotAllAxes
        
        % Function: ShiftNPlot ======================================================
        % Abstract:
        %    Retrieve data from block, time shift it to comply with current scope
        %    limits & offset and assign it to the lines.  Do this for the specied
        %    axis.
        
        function ShiftNPlot(scopeUserData, scopeLineData, axesIdx)
            
            if isempty(scopeLineData), return, end
            
            block        = scopeUserData.block;
            scopeAxes    = scopeUserData.scopeAxes;
            ax           = scopeAxes(axesIdx);
            offset       = get_block_param(block, 'offset');
            tLim         = get(scopeAxes(axesIdx), 'XLim');
            tRange       = tLim(2) - tLim(1);
            axesUserData = get(ax, 'UserData');
            
            [validLines, hLines] = Simulink.scopes.Util.GetAxesLines(block,scopeAxes,axesIdx);
            if ~validLines, return, end
            nLines = length(hLines);
            
            %force erase
            set(hLines, 'Visible', 'off');
            xlim = get(ax,'xlim'); set(ax,'xlim',[-1 1]); set(ax,'xlim',xlim); %force redraw
            set(hLines, 'Visible', 'on');
            
            if ~isstruct(scopeLineData)
                % backward compat matrix form [t dat]
                set_param(block, 'CurrentAxesIdx',axesIdx);
                stairFlags = get_block_param(block,'AxesLineStairFlags');
                stairFlags = [stairFlags{:}];
                
                %
                % Assign data to lines (take care of discrete signals).
                %
                setValues = cell(nLines, 2);
                
                for j=1:nLines,
                    if stairFlags(j)
                        [xData, yData] = ...
                            stairs(scopeLineData(:,1) - offset, double(scopeLineData(:,j+1)));
                        setValues{j,1} = xData;
                        setValues{j,2} = yData;
                    else
                        setValues{j,1} = scopeLineData(:,1) - offset;
                        setValues{j,2} = double(scopeLineData(:,j+1));
                    end
                end
                set(hLines, {'XData', 'YData'}, setValues);
            else
                %structure form
                
                %stairFlags = scopeLineData.signals(axesIdx).plotStyle;
                set_param(block, 'CurrentAxesIdx',axesIdx);
                stairFlags = get_block_param(block,'AxesLineStairFlags');
                stairFlags = [stairFlags{:}];
                
                % If number of dimensions is two, time sequence corresponds to the
                % last dimension, otherwise, time sequence crossponds to the first
                % dimension.
                
                values = scopeLineData.signals(axesIdx).values;
                dims   = scopeLineData.signals(axesIdx).dimensions;
                time   = scopeLineData.time;
                if length(dims) >= 2
                    P = size(values);
                    
                    % Make sure that we have at least 3 dimensions in P so the
                    % calculations below do not transpose the data. g402193
                    %         if length(P) < 3
                    %             P = [P 1];
                    %         end
                    
                    % Reshape data by adding ones at the end when time is scalar
                    if isscalar(time) % g419893
                        values = reshape(values, prod(P), 1).';
                    else
                        values = reshape(values, prod(P(1:end-1)),P(end)).';
                    end
                end
                
                for j=1:nLines,
                    if hLines(j) ~= -1
                        if stairFlags(j)
                            [xData, yData] = ...
                                stairs(time - offset, double(values(:,j)));
                            set(hLines(j), 'XData', xData, 'YData', yData);
                        else
                            set(hLines(j), ...
                                'XData', time - offset, 'YData', double(values(:,j)));
                        end
                    end
                end
            end
        end % ShiftNPlot
        
        % Function: RestoreDefaultAxesLimits ========================================
        % Abstract:
        %    Restore axes to default limits (the limits stored in the block as opposed
        %    to the current limits which may be the result of zooming).  Do this for
        %    each axis.
        
        function RestoreDefaultAxesLimits(scopeFig, scopeUserData)
            
            block     = scopeUserData.block;
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            
            %
            % Reset the limits.
            %
            [tLim, yLim] = Simulink.scopes.Util.ComputeAxesLimits(scopeFig, scopeUserData);
            
            limitsChanged = 0;
            for i=1:nAxes,
                ax = scopeAxes(i);
                
                oldTLim = get(ax, 'XLim');
                oldYLim = get(ax, 'YLim');
                
                if (~all(oldTLim == tLim)) || (~all(oldYLim == yLim(i,:)))
                    
                    limitsChanged = 1;
                    set(ax, 'XLim', tLim, 'YLim', yLim(i,:));
                    if slprivate('onoff',get_block_param(block, 'Wireless'))
                        Simulink.scopes.Util.HiLiteResize(scopeUserData,i,tLim,yLim(i,:));
                    end
                    
                    %
                    % Set the data of all lines to empty prior to resetting the axes limits.
                    % This avoid an annoying flash of the old data before starting the trace for
                    % the current sim.
                    %
                    [validLines, hLines] = Simulink.scopes.Util.GetAxesLines(block,scopeAxes,i);
                    
                    if validLines
                        set(hLines, {'XData';'YData'}, {NaN, NaN});
                    end
                end
            end
            
            if limitsChanged,
                % figure has re-rendered - invalidate the blit buffer
                get_block_param(block, 'InvalidateBlitBuffer');
            end
            
        end % RestoreDefaultAxesLimits
        
        % Function: InitTickOffset ==================================================
        % Abstract:
        %    Initialize offset text ctrl (if required).
        
        function InitTickOffset(scopeUserData, offset)
            
            if ~strcmp(get_block_param(scopeUserData.block, 'TickLabels'), 'off')
                set(scopeUserData.timeOffset, 'String', sprintf('%-16g', offset));
            end
            
        end % InitTickOffset
        
        % Function: GetDataFromPreviousSim ==========================================
        % Abstract:
        %
        % Check for data from the previous sim.  Make sure that the data matches the
        % current scope configuration (e.g., the number of axes present is the same
        % as the number of data sets contained by the logVar).  If the data is not
        % consistent with the scope configuration, we throw it away.  This can
        % happens if the number of ports is changed after the sim has run.
        
        function scopeLineData = GetDataFromPreviousSim(scopeFig, scopeUserData)
            
            block = scopeUserData.block;
            
            scopeLineData = get_block_param(block, 'CopyDataBuffer');
            if isempty(scopeLineData), return, end;
            
            nAxes = length(scopeUserData.scopeAxes);
            
            %
            % Check for matching configurations.  If not a match, throw away the
            % data.  There is one signal per axes (it may be a vector signal).
            %
            if ~isstruct(scopeLineData)
                %backward compatible matrix format
                nSignalsInData = 1;
            else
                %structure format
                nSignalsInData = length(scopeLineData.signals);
            end
            
            if (nAxes ~= nSignalsInData)
                scopeLineData = [];
            end
            
        end % GetDataFromPreviousSim
        
        % Function: IsEmptyLineData =================================================
        % Abstract:
        %
        % Return true if the structure or matrix representing the line data is "empty".
        % "Empty" means that it doesn't exist, or all of its fields are empty.  The
        % latter can happen on error conditions and via the S-function API to models
        % where the logVar can be created, but never filled in.
        
        function empty = IsEmptyLineData(data)
            
            %
            % Here we need to check for signals to be empty because
            % we could heve the time data structure empty.
            %
            
            if (isempty(data) || (isstruct(data) && isempty(data.signals(1).values)))
                empty = 1;
            else
                
                empty = 0;
            end
            
        end % IsEmptyLineData
        
        % Function: OpenFigure ==============================================
        % Abstract:
        %    Process open request for block, this opens the figure
        
        function OpenFigure(block,newFig,scopeFig)
            
            modified       = 0;
            block_diagram  = bdroot(block);
            simStatus      = get_param(block_diagram, 'SimulationStatus');
            
            scopeUserData = get(scopeFig, 'UserData');
            if ~newFig,
                %
                % It's an existing figure.
                %
                switch (get(scopeFig, 'Visible'))
                    
                    case 'on',
                        %
                        % Already visible - pop it to foreground.
                        %
                        figure(scopeFig);
                        
                    case 'off',
                        %
                        % Make it visible and re-initialize.
                        %
                        if ~strcmp(simStatus, 'stopped')
                            Simulink.scopes.Util.CreateLinesIfNeeded(scopeFig, scopeUserData);
                            Simulink.scopes.Util.SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, 'off');
                            Simulink.scopes.Util.RestoreDefaultAxesLimits(scopeFig, scopeUserData);
                            
                            %
                            % Draw the data that we already have.
                            %
                            scopeLineData = get_block_param(block, 'CopyDataBuffer');
                            Simulink.scopes.Util.ShiftNPlotAllAxes(scopeUserData, scopeLineData, 0);
                        else
                            
                            [tLim, yLim, offset] = ...
                                Simulink.scopes.Util.ComputeAxesLimits(scopeFig, scopeUserData);
                            
                            %
                            % Show data from previous sim.
                            %
                            scopeLineData = Simulink.scopes.Util.GetDataFromPreviousSim(scopeFig, scopeUserData);
                            Simulink.scopes.Util.SetEnableForNonRunWithData(scopeFig, scopeUserData);
                            if ~Simulink.scopes.Util.IsEmptyLineData(scopeLineData)
                                %
                                % Have data from previous sim - show it.
                                %
                                Simulink.scopes.Util.CreateLinesIfNeeded(scopeFig, scopeUserData);
                                Simulink.scopes.Util.InitTickOffset(scopeUserData, offset);
                                Simulink.scopes.Util.ShiftNPlotAllAxes(scopeUserData, scopeLineData, 0);
                            end
                            
                            %
                            % Cache the current axes limits for later comparison.  This allows
                            % the proper enabling the "Save axes settings" toolbar button.
                            %
                            Simulink.scopes.Util.UpdateDefLimits(scopeUserData);
                        end
                        
                        set(scopeFig, 'Visible', 'on');
                        
                    otherwise,
                        %
                        % Should never happen (utAssert).
                        %
                        DAStudio.error('Simulink:blocks:InvalidVisibilityString');
                end
                
            else
                %
                % It's a new figure.
                modified = 1; % newly created user data    
                block = scopeUserData.block;
                
                if strcmp(simStatus, 'stopped')
                    [tLim, yLim, offset] = ...
                        Simulink.scopes.Util.ComputeAxesLimits(scopeFig, scopeUserData);
                    
                    %
                    % Show data from previous sim.
                    %
                    scopeLineData = Simulink.scopes.Util.GetDataFromPreviousSim(scopeFig, scopeUserData);
                    if ~Simulink.scopes.Util.IsEmptyLineData(scopeLineData)
                        %
                        % Have data from previous sim - show it.
                        %
                        Simulink.scopes.Util.CreateLinesIfNeeded(scopeFig, scopeUserData);
                        Simulink.scopes.Util.SetEnableForNonRunWithData(scopeFig, scopeUserData);
                        Simulink.scopes.Util.InitTickOffset(scopeUserData, offset);
                        Simulink.scopes.Util.ShiftNPlotAllAxes(scopeUserData, scopeLineData, 0);
                    else
                        %
                        % No data from previous sim - disable everything.
                        %
                        Simulink.scopes.Util.SetEnableForNonRunWithNoData(scopeFig, scopeUserData);
                    end
                    
                    %
                    % Cache the current axes limits for later comparison.  This allows
                    % the proper enabling the "Save axes settings" toolbar button.
                    %
                    Simulink.scopes.Util.UpdateDefLimits(scopeUserData);
                else
                    Simulink.scopes.Util.CreateLinesIfNeeded(scopeFig, scopeUserData);
                    
                    %
                    % Draw the data that we already have.
                    %
                    scopeLineData = get_block_param(block, 'CopyDataBuffer');
                    Simulink.scopes.Util.ShiftNPlotAllAxes(scopeUserData, scopeLineData, 0);
                end
            end
            
            if slprivate('onoff',get_block_param(block,'Floating'))
                param = 'OverrideFloatScopeTimeRange';
            else
                param = 'OverrideScopeTimeRange';
            end
            if ~isnan(get_param(block_diagram, param))
                [modified, scopeUserData] = Simulink.scopes.Util.UpdateAxesConfig(scopeFig, scopeUserData);
            end
            
            if modified,
                set(scopeFig, 'UserData', scopeUserData);
            end
        end % OpenFigure
        
        % Function: CreateLinesIfNeeded =============================================
        % Abstract:
        %    Create the scope lines (if needed) and set them in the scope block.
        
        function CreateLinesIfNeeded(scopeFig, scopeUserData)
            
            block     = scopeUserData.block;
            scopeAxes = scopeUserData.scopeAxes;
            
            nAxes = length(scopeAxes);
            
%             for i=1:nAxes,
%                 newLines = Simulink.scopes.Util.CreateLinesForAxes( ...
%                     scopeFig, scopeUserData, i);
%                 if ~isempty(newLines)
%                     set_param(block, 'AxesLineHandles', newLines);
%                 end
%             end
            allLines = cell(1, nAxes); 
            for i=1:nAxes,
                newLines = Simulink.scopes.Util.CreateLinesForAxes( ...
                    block, scopeUserData, i);
                allLines{i} = newLines;
            end
            ax = get_param(block, 'CurrentAxesIdx');
            set_param(block, 'CurrentAxesIdx', 0); % 0 means all
            set_param(block, 'AxesLineHandles', allLines);
            set_param(block, 'CurrentAxesIdx', ax); % HD to prevent later bugs

            
        end % CreateLinesIfNeeded
        
        % Function: SimulationStart =================================================
        % Abstract:
        %    Perform simulation init tasks.
        
        function [scopeUserData, modified] = SimulationStart(scopeFig, scopeUserData)
            
            modified   = 0;
            block      = scopeUserData.block;
            scopeAxes  = scopeUserData.scopeAxes;
            modelBased = Simulink.scopes.Util.IsModelBased(block);
            
            Simulink.scopes.Util.UpdateAxesConfig(scopeFig,scopeUserData);
            Simulink.scopes.Util.CreateLinesIfNeeded(scopeFig,scopeUserData);
            Simulink.scopes.Util.SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, 'off');
            Simulink.scopes.Util.RestoreDefaultAxesLimits(scopeFig, scopeUserData);
            
            Simulink.scopes.Util.UpdateTitles(scopeUserData);
            
            % Turn off selection rectangle if scope is model-based.
            if modelBased
                Simulink.scopes.Util.HiLiteOff(scopeUserData,get_block_param(scopeUserData.block,'SelectedAxesIdx'));
            end
            
        end % SimulationStart
        
        % Function: BufferInUse =====================================================
        % Abstract:
        %   Return true if the scope is storing data in its buffers.
        
        function bufferInUse = BufferInUse(block)
            
            bufferInUse = ~((strcmp(get_block_param(block, 'LimitDataPoints'), 'on')) && ...
                (evalin('base',get_block_param(block, 'MaxDataPoints')) == 0.0));
            
        end % BufferInUse
        
        % Function: SimulationTerminate =============================================
        % Abstract:
        %    Handle simulation termination.
        
        function [scopeUserData, modified] = ...
                SimulationTerminate(scopeFig, scopeUserData)
            
            block       = scopeUserData.block;
            scopeAxes   = scopeUserData.scopeAxes;
            simStatus   = 'terminating';
            modified    = 0;
            bufferInUse = Simulink.scopes.Util.BufferInUse(block);
            modelBased  = Simulink.scopes.Util.IsModelBased(scopeUserData.block);
            
            %
            % Enable appropriate UI controls.
            %
            Simulink.scopes.Util.SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, 'on');
            
            if bufferInUse,
                %
                % Fill in line data for last screen (currently there are "lit pixels"
                % with no data because we use erasemode none for animation.
                %
                scopeLineData = get_block_param(block, 'CopyDataBuffer');
                if ~Simulink.scopes.Util.IsEmptyLineData(scopeLineData)
                    Simulink.scopes.Util.ShiftNPlotAllAxes(scopeUserData, scopeLineData, 1);
                end
            end
            
            %
            % Cache the current axes limits for later comparison.  This allows
            % the proper enabling the "Save axes settings" toolbar button.
            %
            Simulink.scopes.Util.UpdateDefLimits(scopeUserData);
            
            %
            % Turn zoom on (if needed).
            %
            floating = slprivate('onoff',get_block_param(block, 'Floating'));
            zoomMode = get_block_param(block, 'ZoomMode');
            if bufferInUse && ~floating,
                scopezoom(zoomMode, scopeFig);
                scopezoom('reset', scopeFig);
            end
            
            % Turn on selection rectangle if scope is model-based.  If the user
            % clicked on an axes during simulation, the HG current axes may have
            % changed, so we should fix it here.
            if modelBased
                selAxesIdx = get_block_param(block,'SelectedAxesIdx');
                set(get_block_param(block,'Figure'), 'CurrentAxes', scopeAxes(selAxesIdx));
                Simulink.scopes.Util.HiLiteOn(scopeUserData,selAxesIdx);
            end
        end % SimulationTerminate
        
        % Function: ResizeAxes ======================================================
        % Abstract:
        %    Handle all the tasks needed to be done when resizing an axes.
        
        function [modified, scopeUserData] = ...
                ResizeAxes(scopeFig, scopeUserData, axesGeom)
            
            modified        = 0;
            scopeAxes       = scopeUserData.scopeAxes;
            nAxes           = length(scopeAxes);
            axesGeom        = Simulink.scopes.Util.CreateAxesGeom(scopeFig,scopeUserData);
            axesInfo        = Simulink.scopes.Util.ComputeAxesInfo(scopeFig, scopeUserData, axesGeom, nAxes);
   
            for i=1:length(scopeAxes)
                set(scopeAxes(i), ...
                    'XTickLabel',     [], ...
                    'XTickLabelMode', axesInfo(i).XTickLabelMode, ...
                    'Position',       axesInfo(i).Position);
                Simulink.scopes.Util.SetYTickInfo(scopeAxes(i), axesInfo(i).YTickInfo);
            end
            Simulink.scopes.Util.FixPositionOfAxes(scopeUserData);
            
            if ~strcmp(scopeUserData.tickLabelOpt, axesGeom.tickLabelOpt)
                modified = 1;
                scopeUserData.tickLabelOpt = axesGeom.tickLabelOpt;
            end
            
            % figure has re-rendered - invalidate the blit buffer
            block           = scopeUserData.block;
            get_block_param(block, 'InvalidateBlitBuffer');
            
        end % ResizeAxes
        
        
        % Function: SetEnableForNonRuntimeCtrls =====================================
        % Abstract:
        %    Disable/Enable UI ctrls that are not appropriate for runtime use.
        
        function SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, onoffState)
            
            switch(onoffState)
                
                case 'on',
                    state = 'notrunning';
                    
                case 'off',
                    state = 'running';
                    scopezoom('off', scopeFig);
                    
                otherwise,
                    DAStudio.error('Simulink:blocks:InvalidState');
            end
            
            scopebar(scopeFig, 'CtrlUI', state);
            
        end % SetEnableForNonRuntimeCtrls
        
        % Function: SetEnableForNonRunWithData ======================================
        % Abstract:
        %    Set enabled for case of opening a scope in a non-running block diagram
        %    with previous simulation data.
        
        function SetEnableForNonRunWithData(scopeFig, scopeUserData)
            
            children = scopeUserData.toolbar.children;
            block    = scopeUserData.block;
            floating = slprivate('onoff',get_block_param(block, 'Floating'));
            
            if ~floating,
                iconsOn = [
                    children.modeIcons.ZoomNormal
                    children.modeIcons.ZoomX
                    children.modeIcons.ZoomY
                    children.actionIcons.Print
                    children.actionIcons.Find];
                
                iconsOff = [];
                zoomMode = get_block_param(block, 'ZoomMode');
            else
                iconsOn =[];
                
                iconsOff = [
                    children.modeIcons.ZoomNormal
                    children.modeIcons.ZoomX
                    children.modeIcons.ZoomY
                    children.actionIcons.Print
                    children.actionIcons.Find];
                
                zoomMode = 'off';
            end
            
            scopebar(scopeFig, 'EnableIcon', iconsOn,  'on');
            scopebar(scopeFig, 'EnableIcon', iconsOff, 'off');
            scopezoom(zoomMode, scopeFig);
            
        end %SetEnableForNonRunWithData
        
        % Function: SetEnableForNonRunWithNoData ====================================
        % Abstract:
        %    Set enabled for case of opening a scope in a non-running block diagram
        %    with no previous simulation data.
        
        function SetEnableForNonRunWithNoData(scopeFig, scopeUserData)
            
            children = scopeUserData.toolbar.children;
            block    = scopeUserData.block;
            
            iconsOff = [
                children.modeIcons.ZoomNormal
                children.modeIcons.ZoomX
                children.modeIcons.ZoomY
                children.actionIcons.Find];
            
            scopebar(scopeFig, 'EnableIcon', iconsOff,  'off');
            scopezoom('off', scopeFig);
        end % SetEnableForNonRunWithNoData
        
        % Function: DisableZoom =====================================================
        % Abstract:
        %    Disable zoom buttons on the scope bar.
        %
        
        function DisableZoom(scopeFig, scopeUserData)
            
            children = scopeUserData.toolbar.children;
            block    = scopeUserData.block;
            
            iconsOff = [
                children.modeIcons.ZoomNormal
                children.modeIcons.ZoomX
                children.modeIcons.ZoomY];
            
            scopebar(scopeFig, 'EnableIcon', iconsOff,  'off');
            scopezoom('off', scopeFig);
            
        end % DisableZoom
        
        % Function: CreateTimeOffsetCtrls ===========================================
        % Abstract:
        %    Create text objects for time offset.
        
        function scopeUserData = CreateTimeOffsetCtrls(scopeFig, scopeUserData)
            
            scopeAxes     = scopeUserData.scopeAxes(end);
            block         = scopeUserData.block;
            txtColor      = get(scopeAxes, 'XColor');
            scopeFigColor = get(scopeFig, 'Color');
            
            %
            % Determine size of text label.
            %
            textExtent = scopeUserData.textExtent;
            set(textExtent, ...
                'FontName',       scopeUserData.uiFontName, ...
                'FontSize',       scopeUserData.uiFontSize, ...
                'String',         [Simulink.scopes.Util.lclMessage('ScopeTimeOffset') ' ']);
            ext = get(textExtent, 'Extent');
            pos = [1, 1, ext(3), ext(4)];
            
            %
            % Create text label.
            %
            scopeUserData.timeOffsetLabel = uicontrol( ...
                'Parent',             scopeFig, ...
                'Style',              'text', ...
                'String',             Simulink.scopes.Util.lclMessage('ScopeTimeOffset'), ...
                'Position',           pos, ...
                'ForegroundColor',    txtColor, ...
                'BackgroundColor',    scopeFigColor, ...
                'Visible',            'on');
            
            %
            % Create offset text object.
            %
            pos(1) = pos(1) + pos(3) + 2;
            pos(3) = 100;
            
            scopeUserData.timeOffset = uicontrol( ...
                'Parent',             scopeFig, ...
                'Style',              'text', ...
				'tag', 'TimeOffsetValue', ...
                'Position',           pos, ...
                'ForegroundColor',    txtColor, ...
                'BackgroundColor',    scopeFigColor, ...
                'Visible',            'on');
            
            %
            % Hand the block the uicontrols handle.
            set_param(block, 'TimeOffsetHandle', double(scopeUserData.timeOffset));
            
        end % CreateTimeOffsetCtrls
        
        % Function: GetStrField =====================================================
        % Abstract:
        %    Given a block string delimited by '~' (e.g., ymin, ymax, titles), return
        %    the i'th field.  The string MUST be of the form: 'field1~field2~field3'
        
        function outStr = GetStrField(inStr, i)
            
            if isempty(inStr)
                outStr = '';
                return;
            end
            
            toks   = [0 find(inStr == '~') length(inStr)+1];
            start  = toks(i)+1;
            stop   = toks(i+1) - 1;
            
            outStr = inStr(start:stop);
            
        end % GetStrField
        
        % Function: SetStrField =====================================================
        % Abstract:
        %    Given a block string delimited by '~' (e.g., ymin, ymax, titles), set
        %    the i'th field to the new value.  The string must be of the form:
        %
        %    'field1~field2~field3'
        
        function outStr = SetStrField(inStr, i, newStr)
            
            if ~isempty(inStr)
                toks   = [0 find(inStr == '~') length(inStr)+1];
                start  = toks(i)+1;
                stop   = toks(i+1) - 1;
                
                outStr = [inStr(1:toks(i)) newStr inStr(toks(i+1):end)];
            else
                outStr = newStr;
            end
            
        end % SetStrField
        
        % Function: GetAxesPropDlgName ==============================================
        % Abstract:
        %
        function dlgName = GetAxesPropDlgName(ax, block, axesIdxStr)
            
            hTitle   = get(ax, 'Title');
            titleStr = get(hTitle, 'String');
            
            if ~isempty(titleStr) && ~all(titleStr == ' ')
                dlgName = Simulink.scopes.Util.lclMessage('ScopeAxesPropertiesTitle', get_block_param(block, 'name'), titleStr);
            else
                dlgName = Simulink.scopes.Util.lclMessage('ScopeAxesPropertiesTitleAxis', get_block_param(block, 'name'), axesIdxStr);
            end
            
        end % GetAxesPropDlgName
        
        % Function: SyncAxPropertiesDialog ==========================================
        % Abstract:
        %    Sync fields of axes property dialog with block.
        
        function SyncAxPropertiesDialog(block, dialogUserData, axesIdx)
            
            children = dialogUserData.children;
            
            h            = children.yMinEdit;
            blockYMinStr = get_block_param(block, 'YMin');
            str          = Simulink.scopes.Util.GetStrField(blockYMinStr, axesIdx);
            set(h, 'String', str);
            
            h            = children.yMaxEdit;
            blockYMaxStr = get_block_param(block, 'YMax');
            str          = Simulink.scopes.Util.GetStrField(blockYMaxStr, axesIdx);
            set(h, 'String', str);
            
            h            = children.titleEdit;
            blockTitles  = Simulink.scopes.Util.struct2cell(get_block_param(block, 'AxesTitles'));
            str          = blockTitles{axesIdx};
            set(h, 'String', str);
            
        end % SyncAxPropertiesDialog
        
        % Function: CreateAxPropertiesDialog ========================================
        % Abstract:
        %    Create the properties dialog box for the specified axis.  If it exist,
        %    pop it to the foreground.
        
        function CreateAxPropertiesDialog(scopeFig, scopeUserData, axesIdx)
            
            ax         = scopeUserData.scopeAxes(axesIdx);
            axUserData = get(ax, 'UserData');
            block      = scopeUserData.block;
            axesIdxStr = sprintf('%d',axesIdx);
            
            %
            % If it already exist, bring it to the foreground.
            %
            if ishandle(axUserData.propDlg)
                figure(axUserData.propDlg);
                return;
            end
            
            % Create the figure first to compute accurate text extent
            %
            fontName = get(0, 'FactoryUIControlFontName');
            fontSize = get(0, 'FactoryUIControlFontSize');
            color    = get(0, 'FactoryUIControlBackgroundColor');
            
            dlgName   = Simulink.scopes.Util.GetAxesPropDlgName(ax, block, axesIdxStr);
            
            deleteFcn = ['simscope(''AxesPropDlg'', ''FigDeleteFcn'', gcbf, ' axesIdxStr ')'];
            
            dialogFig = figure( ...
                'Visible',                            'off', ...
                'DefaultUIControlHorizontalAlign',    'left', ...
                'DefaultUIControlFontname',           fontName, ...
                'DefaultUIControlFontsize',           fontSize, ...
                'DefaultUIControlUnits',              'character', ...
                'DefaultUIControlBackgroundColor',    color, ...
                'HandleVisibility',                   'off', ...
                'Colormap',                           [], ...
                'Name',                               dlgName, ...
                'Tag',                                'SCOPE_AXES_PROPERTIES', ...
                'IntegerHandle',                      'off', ...
                'Resize',                             'off', ...
                'Units',                              'character', ...
                'MenuBar',                            'none', ...
                'Color',                              color, ...
                'NumberTitle',                        'off', ...
                'DeleteFcn',                          deleteFcn);
            
            % Use this control to compute accurate extent of text controls
            hExtentControl = uicontrol('Parent', dialogFig, 'style','text'); 
            
            %
            % Create geometry contants.
            %
            sysOffsets = sluigeom('character');
            
            maxTitleWidth = 'This seems like a pretty good max title width   ';
            
            dlgGeom.hText          = 1 + sysOffsets.text(4);
            dlgGeom.hEdit          = 1 + sysOffsets.edit(4);
            dlgGeom.wYMinLabel     = uiwidth(hExtentControl, xlate('Y-min:'))+1;
            dlgGeom.wYMaxLabel     = uiwidth(hExtentControl, xlate('Y-max:'))+1;
            dlgGeom.wStdEdit       = length('0.123456789012') + sysOffsets.edit(3);
            dlgGeom.colSpace       = 4;
            dlgGeom.rowSpace       = 1;
            dlgGeom.topFigSpace    = 1;
            dlgGeom.bottomFigSpace = 0.5;
            dlgGeom.sideFigSpace   = 2;
            dlgGeom.titleLabel     = ['Title (''' get_block_param(block,'DefaultAxesTitlesString') ''' replaced by signal name): '];
            dlgGeom.wTitleLabel    = length(dlgGeom.titleLabel);
            dlgGeom.wTitleEdit     = length(maxTitleWidth);
            dlgGeom.hSpacer        = 1.25;
            dlgGeom.wSysButton     = 9   + sysOffsets.pushbutton(3);
            dlgGeom.hSysButton     = 1.1 + sysOffsets.pushbutton(4);
            dlgGeom.sysButtonDelta = 1.2;
            
            % clean up
            delete(hExtentControl);
            
            %
            % Calculate fig width and height.
            %
            row1 = ...
                dlgGeom.wYMinLabel + ...
                dlgGeom.wYMaxLabel + ...
                (dlgGeom.colSpace + (2 * dlgGeom.wStdEdit));
            
            wAllSysButtons = (3 * dlgGeom.wSysButton) + (2 * dlgGeom.sysButtonDelta);
            
            widestRow = max([row1, dlgGeom.wTitleLabel, dlgGeom.wTitleEdit, wAllSysButtons]);
            
            wDlg = widestRow + (2 * dlgGeom.sideFigSpace);
            
            hDlg = ...
                dlgGeom.topFigSpace + ...
                dlgGeom.hEdit       + ...
                dlgGeom.hSpacer     + ...
                dlgGeom.hText       + ...
                dlgGeom.hEdit       + ...
                dlgGeom.hSpacer     + ...
                dlgGeom.hSysButton  + ...
                dlgGeom.bottomFigSpace;
            
            %
            % Calculate ctrl positions.
            %
            cxCur = dlgGeom.sideFigSpace;
            cyCur = hDlg - dlgGeom.topFigSpace - dlgGeom.hEdit;
            
            ctrlPos.yMinLabel = [cxCur cyCur dlgGeom.wYMinLabel, dlgGeom.hText];
            
            cxCur = cxCur + dlgGeom.wYMinLabel;
            ctrlPos.yMinEdit = [cxCur cyCur dlgGeom.wStdEdit dlgGeom.hEdit];
            
            cxCur = cxCur + dlgGeom.wStdEdit + dlgGeom.colSpace;
            ctrlPos.yMaxLabel = [cxCur cyCur dlgGeom.wYMaxLabel, dlgGeom.hText];
            
            cxCur = cxCur + dlgGeom.wYMaxLabel;
            ctrlPos.yMaxEdit = [cxCur cyCur dlgGeom.wStdEdit dlgGeom.hEdit];
            
            cxCur = dlgGeom.sideFigSpace;
            cyCur = cyCur - dlgGeom.hSpacer - dlgGeom.hText;
            ctrlPos.titleLabel = [cxCur cyCur dlgGeom.wTitleLabel dlgGeom.hText];
            
            cyCur    = cyCur - dlgGeom.hText;
            tmpWidth = max(dlgGeom.wTitleLabel, (wDlg - (2*dlgGeom.sideFigSpace)));
            ctrlPos.titleEdit = [cxCur cyCur tmpWidth dlgGeom.hEdit];
            
            cxCur = wDlg -  dlgGeom.sideFigSpace - wAllSysButtons;
            cyCur = cyCur - dlgGeom.hSpacer - dlgGeom.hSysButton;
            ctrlPos.ok = [cxCur cyCur dlgGeom.wSysButton dlgGeom.hSysButton];
            
            cxCur = cxCur + dlgGeom.wSysButton + dlgGeom.sysButtonDelta;
            ctrlPos.cancel = [cxCur cyCur dlgGeom.wSysButton dlgGeom.hSysButton];
            
            cxCur = cxCur + dlgGeom.wSysButton + dlgGeom.sysButtonDelta;
            ctrlPos.apply = [cxCur cyCur dlgGeom.wSysButton dlgGeom.hSysButton];
            
            % g500766: Since this geck was NAP-ped
            % and setting the units to character started
            % refiring the Resize event from R2008b
            % we want to continue not firing the resize event
            % So setting the resizeFcn to null before set.
            
            resizeFcn = get(scopeFig,'resizeFcn');
            set(scopeFig,'resizeFcn','');
            %
            % Calculate figure position (in character units).
            %
            figUnits  = get(scopeFig, 'Units');
            axUnits   = get(ax, 'Units');
            set([scopeFig ax], 'Units', 'character');
            
            scopePos = get(scopeFig, 'Position');
            axPos    = get(ax, 'Position');
            
            cxAxCenter = scopePos(1) + axPos(1);
            cyAxCenter = scopePos(2) + axPos(2);
            
            set(scopeFig, 'Units', figUnits);
            set(ax,       'Units', axUnits);
            
            % Reset resizeFcn to the original value after
            % resetting of units is done.
            set(scopeFig,'resizeFcn',resizeFcn);
            
            xposDlg = cxAxCenter - (wDlg/2);
            if xposDlg < 0, xposDlg = 0; end;
            yposDlg = cyAxCenter - (hDlg/2);
            if yposDlg < 5, yposDlg = 5; end;
            
            pos = [ xposDlg, yposDlg, wDlg, hDlg ];
            set(dialogFig, 'Position', pos);
            
            %
            % Set up the figure's user data.
            %
            dialogUserData.parent   = scopeFig;
            dialogUserData.axesIdx  = axesIdx;
            dialogUserData.children = [];
            
            axUserData.propDlg = dialogFig;
            set(ax, 'UserData', axUserData);
            
            %
            % Create the uicontrols.
            %
            children.yMinLabel = uicontrol( ...
                'Parent',           dialogFig, ...
                'Style',            'text', ...
                'String',           xlate('Y-min:'), ...
                'Position',         ctrlPos.yMinLabel);
            
            children.yMinEdit = uicontrol( ...
                'Parent',           dialogFig,...
                'Style',            'edit',...
				'Tag',              'ScopeAxesPropertiesYMinValue', ...
                'BackgroundColor',  'w',...
                'Position',         ctrlPos.yMinEdit);
            
            children.yMaxLabel = uicontrol( ...
                'Parent',           dialogFig, ...
                'Style',            'text', ...
                'String',           xlate('Y-max:'), ...
                'Position',         ctrlPos.yMaxLabel);
            
            children.yMaxEdit = uicontrol( ...
                'Parent',           dialogFig,...
                'Style',            'edit',...
				'Tag',              'ScopeAxesPropertiesYMaxValue', ...
                'BackgroundColor',  'w',...
                'Position',         ctrlPos.yMaxEdit);
            
            children.titleLabel = uicontrol( ...
                'Parent',           dialogFig, ...
                'Style',            'text', ...
                'String',           dlgGeom.titleLabel, ...
                'Position',         ctrlPos.titleLabel);
            
            children.titleEdit = uicontrol( ...
                'Parent',           dialogFig,...
                'Style',            'edit',...
				'Tag',              'ScopeAxesPropertiesTitleValue', ...
                'BackgroundColor',  'w',...
                'Position',         ctrlPos.titleEdit);
            
            children.ok = uicontrol( ...
                'Parent',               dialogFig, ...
                'Style',                'pushbutton', ...
                'String',               'OK', ...
				'Tag',                  'OKButton', ...
                'HorizontalAlignment',  'center', ...
                'Position',             ctrlPos.ok);
            
            children.cancel = uicontrol( ...
                'Parent',               dialogFig, ...
                'Style',                'pushbutton', ...
                'String',               Simulink.scopes.Util.lclMessage('CancelButton'), ...
				'Tag',                  'CancelButton', ...
                'Enable',               'on', ...
                'HorizontalAlignment',  'center', ...
                'Position',             ctrlPos.cancel);
            
            children.apply = uicontrol( ...
                'Parent',               dialogFig, ...
                'Style',                'pushbutton', ...
                'String',               Simulink.scopes.Util.lclMessage('ApplyButton'), ...
				'Tag',                  'ApplyButton', ...
                'HorizontalAlignment',  'center', ...
                'Position',             ctrlPos.apply);
            
            dialogUserData.children = children;
            
            Simulink.scopes.Util.SyncAxPropertiesDialog(block, dialogUserData, axesIdx);
            
            %
            % Install callbacks.
            %
            h  = children.ok;
            cb = ['simscope(''AxesPropDlg'', ''OK'', gcbf, ' axesIdxStr ')'];
            set(h, 'Callback', cb);
            
            h  = children.cancel;
            cb = ['simscope(''AxesPropDlg'', ''Cancel'', gcbf, ' axesIdxStr ')'];
            set(h, 'Callback', cb);
            
            h  = children.apply;
            cb = ['simscope(''AxesPropDlg'', ''Apply'', gcbf, ' axesIdxStr ')'];
            set(h, 'Callback', cb);
            
            %
            % Install user data and show figure.
            %
            dialogUserData.block = block;
            set(dialogFig, 'UserData', dialogUserData, 'Visible', 'on');
            
        end % CreateAxPropertiesDialog
        
        % Function: SimpleSimStatus =================================================
        % Abstract:
        %  Get the simplified status of the simulation.  This is the usual
        %  'SimulationStatus' of the block diagram, with 'external' mapped to either
        %  'running' or 'stopped'.  In external mode, the state will be 'stopped' if
        %  the uploadStatus is 'inactive' or 'running' otherwise.
        function status = SimpleSimStatus(hMdl)
            status        = get_param(hMdl, 'SimulationStatus');
            uploadStatus  = get_param(hMdl, 'ExtModeUploadStatus');
            
            if strcmp(status, 'external')
                if ~strcmp(uploadStatus, 'inactive')
                    status = 'running';
                else
                    status = 'stopped';
                end
            end
            
        end % function SimpleSimStatus
        
        
        % Function: RestoreYLimits ==================================================
        % Abstract:
        %    Restore the y limits of all axes to the values saved in the block.
        function RestoreYLimits(scopeFig, scopeUserData)
            
            wireless      = slprivate('onoff',get_block_param(scopeUserData.block, 'Wireless'));
            simStatus     = Simulink.scopes.Util.SimpleSimStatus(scopeUserData.block_diagram);
            
            for k=1:length(scopeUserData.scopeAxes)
                ax = scopeUserData.scopeAxes(k);
                scopezoom('restore', ax, simStatus);
                newXLim = get(ax, 'XLim');
                newYLim = get(ax, 'YLim');
                if wireless,
                    Simulink.scopes.Util.HiLiteResize(scopeUserData,k,newXLim,newYLim);
                end
            end
            
            % get_param(block, 'InvalidateBlitBuffer');
            
        end % RestoreYLimits
        
        % Function: UpdateYLimits ===================================================
        % Abstract:
        %    Update the y-limits of the designated axes based on the current
        %    block settings.
        
        function UpdateYLimits(scopeFig, scopeUserData, axesArray)
            
            block                = scopeUserData.block;
            scopeAxes            = scopeUserData.scopeAxes;
            nAxes                = length(scopeAxes);
            if nargin < 3
                axesArray = (1:nAxes);
            end
            wireless             = slprivate('onoff',get_block_param(block, 'Wireless'));
            [tLim, yLim] = Simulink.scopes.Util.ComputeAxesLimits(scopeFig, scopeUserData);
            
            modified = 0;
            for i=1:length(axesArray)
                axesIdx = axesArray(i);
                ax           = scopeAxes(axesIdx);
                axesUserData = get(ax, 'UserData');
                currentYLim  = get(ax, 'YLim');
                newYLim      = yLim(axesIdx,:);
                if ~all(currentYLim == newYLim),
                    currentXLim  = get(ax, 'XLim');
                    set(ax, 'YLim', newYLim);
                    if wireless,
                        Simulink.scopes.Util.HiLiteResize(scopeUserData,axesIdx,currentXLim,newYLim);
                    end
                    
                    axesUserData.defYLim = newYLim;
                    set(ax, 'UserData', axesUserData);
                    
                    modified = 1;
                end
            end
            
            if (modified),
                % figure has re-rendered - invalidate the blit buffer
                get_block_param(block, 'InvalidateBlitBuffer');
            end
        end % UpdateYLimits
        
        % Function: ApplyAxesPropDialog =============================================
        % Abstract:
        %    Handle the applying of properties for the axes property dialog.
        
        function error = ApplyAxesPropDialog(dialogFig, axesIdx)
            
            error          = 0;
            dialogUserData = get(dialogFig, 'UserData');
            scopeFig       = dialogUserData.parent;
            scopeUserData  = get(scopeFig, 'UserData');
            block          = scopeUserData.block;
            children       = dialogUserData.children;
            
            %
            % Validate ymin and ymax
            %
            h       = children.yMinEdit;
            yMinStr = deblank(get(h, 'String'));
            try
                yMinVal = evalin('base', yMinStr);
                if isnan(yMinVal)
                    error = 1;
                end
            catch me %#ok<NASGU>
                error = 1;
            end
            if error,
                beep;
                errordlg(Simulink.scopes.Util.lclMessage('InvalidYMinEntry'), 'Error', 'modal');
                return;
            end
            
            h         = children.yMaxEdit;
            yMaxStr   = deblank(get(h, 'String'));
            try
                yMaxVal = evalin('base', yMaxStr);
                if isnan(yMaxVal)
                    error = 1;
                end
            catch me %#ok<NASGU>
                error = 1;
            end
            if error,
                beep;
                errordlg(Simulink.scopes.Util.lclMessage('InvalidYMaxEntry'), 'Error', 'modal');
                return;
            end
            
            if (length(yMinVal) ~= 1) || (length(yMaxVal) ~= 1) || (yMinVal >= yMaxVal)
                beep;
                error = 1;
                errordlg(Simulink.scopes.Util.lclMessage('InvalidYMinOrYMaxEntry'), 'Error', 'modal');
                return;
            end
            
            yMinStr = sprintf('%0.16g', yMinVal);
            yMaxStr = sprintf('%0.16g', yMaxVal);
            
            
            %
            % Create new 'Y-min' and 'Y-max' strings in block.  Note that these strings
            % represent the setting for all axes.
            %
            blockYMinStr = get_block_param(block, 'YMin');
            blockYMinStr = Simulink.scopes.Util.SetStrField(blockYMinStr, axesIdx, yMinStr);
            
            blockYMaxStr = get_block_param(block, 'YMax');
            blockYMaxStr = Simulink.scopes.Util.SetStrField(blockYMaxStr, axesIdx, yMaxStr);
            
            %
            % Create new titles string in block.
            %
            h           = children.titleEdit;
            titleStr    = get(h,'String');
            blockTitles = Simulink.scopes.Util.struct2cell(get_block_param(block, 'AxesTitles'));
            if isempty(titleStr), titleStr = ' '; end;
            blockTitles{axesIdx} = titleStr;
            
            %
            % Update the block settings and update the figure.
            %
            set_param(block, ...
                'YMin',       blockYMinStr, ...
                'Ymax',       blockYMaxStr, ...
                'AxesTitles', Simulink.scopes.Util.TitleCell2Struct(blockTitles));
            
            Simulink.scopes.Util.UpdateYLimits(scopeFig, scopeUserData, axesIdx);
            Simulink.scopes.Util.UpdateTitles(scopeUserData);
            
        end % ApplyAxesPropDialog
        
        % Function: ManageAxesPropDlg ===============================================
        % Abstract:
        %    Handle callbacks for the axes property dialog.
        
        function ManageAxesPropDlg(dialogAction, dialogFig, axesIdx)
            
            dialogUserData = get(dialogFig, 'UserData');
            scopeFig       = dialogUserData.parent;
            
            switch(dialogAction)
                
                case 'OK',
                    error = Simulink.scopes.Util.ApplyAxesPropDialog(dialogFig, axesIdx);
                    if ~error,
                        close(dialogFig);
                    end
                    scopeUserData = get(scopeFig, 'UserData');
                    
                    % Call Simulink.scopes.Util.ResizeAxes in case y-axis tick labels have grown
                    %  one character bigger
                    axesGeom      = Simulink.scopes.Util.CreateAxesGeom(scopeFig, scopeUserData);
                    scopeUserData = Simulink.scopes.Util.ResizeAxes(scopeFig, scopeUserData, axesGeom);
                    
                case 'Cancel',
                    close(dialogFig);
                    
                case 'Apply',
                    Simulink.scopes.Util.ApplyAxesPropDialog(dialogFig, axesIdx);
                    scopeUserData = get(scopeFig, 'UserData');
                    
                    % Call Simulink.scopes.Util.ResizeAxes in case y-axis tick labels have grown
                    %  one character bigger
                    axesGeom      = Simulink.scopes.Util.CreateAxesGeom(scopeFig, scopeUserData);
                    scopeUserData = Simulink.scopes.Util.ResizeAxes(scopeFig, scopeUserData, axesGeom);
                    
                case 'FigDeleteFcn',
                    dialogUserData = get(dialogFig, 'UserData');
                    scopeFig       = dialogUserData.parent;
                    scopeUserData  = get(scopeFig, 'UserData');
                    scopeAxes      = scopeUserData.scopeAxes;
                    ax             = scopeAxes(axesIdx);
                    
                    axUserData = get(ax, 'UserData');
                    axUserData.propDlg = INVALID_HANDLE;
                    set(ax, 'UserData', axUserData);
                    
                otherwise,
                    DAStudio.error('Simulink:blocks:UnexpectedDialogAction');
            end
        end % ManageAxesPropDlg
        
        % Function: SyncAxesSettingsAll =============================================
        % Abstract:
        %
        function SyncAxesSettingsAll(scopeFig, scopeUserData)
            
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            
            for i=1:nAxes,
                ax           = scopeAxes(i);
                axesUserData = get(ax, 'UserData');
                Simulink.scopes.Util.SyncAxesSettings(scopeFig, scopeUserData, ax, axesUserData)
            end
            
            if ishandle(scopeUserData.scopePropDlg)
                scpprop('SyncCallBack', scopeUserData.scopePropDlg);
            end
            
        end % SyncAxesSettingsAll
        
        % Function: SyncAxesSettings ================================================
        % Abstract:
        %    Sync the axes settings for the current axes.
        
        function SyncAxesSettings(scopeFig, scopeUserData, ax, axesUserData)
            
            axesIdx  = axesUserData.idx;
            block    = scopeUserData.block;
            wireless = slprivate('onoff',get_block_param(block, 'Wireless'));
            
            %
            % Get limits and limit strings for current axes.
            %
            xLim  = get(ax, 'XLim');
            xSpan = xLim(2) - xLim(1);
            if isinf(xSpan)
                xLim = Simulink.scopes.Util.ComputeAxesLimits(scopeFig, scopeUserData);
                xSpan = xLim(2) - xLim(1);
            end
            
            xLimStr = sprintf('%0.16g', xSpan);
            
            yLim    = get(ax, 'YLim');
            yMinStr = sprintf('%0.16g', yLim(1));
            yMaxStr = sprintf('%0.16g', yLim(2));
            
            %
            % Get block wide setting strings and modify with new settings.
            %
            blockYMinStr = get_block_param(block, 'YMin');
            blockYMaxStr = get_block_param(block, 'YMax');
            
            blockYMinStr = Simulink.scopes.Util.SetStrField(blockYMinStr, axesIdx, yMinStr);
            blockYMaxStr = Simulink.scopes.Util.SetStrField(blockYMaxStr, axesIdx, yMaxStr);
            
            set_param(block, ...
                'YMin',         blockYMinStr, ...
                'YMax',         blockYMaxStr, ...
                'TimeRange',    xLimStr);
            
            if ishandle(axesUserData.propDlg)
                dialogUserData = get(axesUserData.propDlg, 'UserData');
                Simulink.scopes.Util.SyncAxPropertiesDialog(block, dialogUserData, axesIdx);
            end
            
            %
            % Update the cached default limits.
            %
            axesUserData.defXLim = xLim;
            axesUserData.defYLim = yLim;
            set(ax, 'UserData', axesUserData);
            
        end % SyncAxesSettings
        
        % Function: AdjustContextMenuItems ==========================================
        % Abstract:
        %    Based on current simulation state and other scope states, update the
        %    status of the context menus (e.g., enabledness of items).
        
        function AdjustContextMenuItems(ax, axesUserData, scopeUserData, simStatus)
            
            h1         =  scopeUserData.axesContextMenu.sync;
            h2         =  scopeUserData.axesContextMenu.select;
            block      =  scopeUserData.block;
            floating   =  slprivate('onoff',get_block_param(block,'Floating'));
            modelbased =  Simulink.scopes.Util.IsModelBased(block);
            
            
            if ~strcmp(simStatus, 'stopped')
                set(h1, 'Enable', 'off');
            else
                if ~all(axesUserData.defXLim == get(ax, 'XLim'))
                    set(h1, 'Enable', 'on');
                else
                    set(h1, 'Enable', 'off');
                end
            end
            
            % Turn on the signal selector option if necessary
            if usejava('MWT')
                set(h2, 'Visible', 'on');
                if modelbased
                    if strcmp(simStatus, 'stopped')
                        set(h2, 'Enable', 'on');
                    else
                        set(h2, 'Enable', 'off');
                    end
                elseif floating
                    set(h2, 'Enable', 'on');
                else
                    set(h2, 'Enable', 'off');
                end
            else
                set(h2, 'Visible', 'off');
            end
            
        end % AdjustContextMenuItems
        
        % Function: ManageContextMenuCB =============================================
        % Abstract:
        %    Handle callback for axes context menus.
        
        function [modified, scopeUserData] = ManageContextMenuCB( ...
                scopeFig, scopeUserData, contextAxes, menuItem)
            
            modified = 0;
            
            axesUserData  = get(contextAxes, 'UserData');
            axesIdx       = axesUserData.idx;
            
            switch(menuItem)
                
                case 'ZoomOut',
                    scopezoom('butdwn', 'ContextMenu');
                    
                case 'Adjust',
                    bd            = scopeUserData.block_diagram;
                    simStatus     = get_param(bd, 'SimulationStatus');
                    scopeAxes     = scopeUserData.scopeAxes;
                    ax            = scopeAxes(axesIdx);
                    
                    Simulink.scopes.Util.AdjustContextMenuItems(ax, axesUserData, scopeUserData, simStatus);
                    
                case 'Find',
                    block_diagram = scopeUserData.block_diagram;
                    simStatus     = get_param(block_diagram, 'SimulationStatus');
                    
                    [updatedX, updatedY] = Simulink.scopes.Util.FindRequest(scopeUserData, simStatus, axesIdx);
                    if updatedX || updatedY,
                        get_block_param(scopeUserData.block, 'InvalidateBlitBuffer');
                    end
                    
                case 'Select',
                    %
                    % User requested a selection dialog for signals:
                    % Need to set the source to be the current (blue) axes.
                    %
                    simscope('SelectedAxes', 'Dialog', scopeFig);
                    signalselector('Create', 'simscope', ...
                        scopeUserData.block, ...
                        str2num(get_block_param(scopeUserData.block, 'NumInputPorts')), ...
                        axesIdx, ...
                        DAStudio.message('Simulink:blocks:ScopeAxes'), ...
                        1,...  % Allow multiple selections
                        Simulink.scopes.Util.SignalSelectorTitle(scopeUserData.block));
                    
                    
                case 'Sync',
                    scopeAxes = scopeUserData.scopeAxes;
                    ax        = scopeAxes(axesIdx);
                    
                    Simulink.scopes.Util.SyncAxesSettings(scopeFig, scopeUserData, ax, axesUserData);
                    if ishandle(scopeUserData.scopePropDlg)
                        scpprop('SyncCallBack', scopeUserData.scopePropDlg);
                    end
                    
                case 'Properties',
                    Simulink.scopes.Util.CreateAxPropertiesDialog(scopeFig, scopeUserData, axesIdx);
                    
                otherwise,
                    DAStudio.error('Simulink:blocks:UnexpectedMenuItemWS');
                    
            end
            
        end % ManageContextMenuCB
        
        % Function: FindRequestAllAxes ==============================================
        % Abstract:
        %    Issue a find request for each axes.
        
        function FindRequestAllAxes(scopeFig, scopeUserData)
            
            scopeAxes    = scopeUserData.scopeAxes;
            nAxes        = length(scopeAxes);
            simStatus    = Simulink.scopes.Util.SimpleSimStatus(scopeUserData.block_diagram);
            
            invalidateBlitBuf = 0;
            for i=1:nAxes,
                [updatedX, updatedY] = Simulink.scopes.Util.FindRequest(scopeUserData, simStatus, i);
                if updatedX || updatedY,
                    invalidateBlitBuf = 1;
                end
            end
            
            if invalidateBlitBuf,
                get_block_param(scopeUserData.block, 'InvalidateBlitBuffer');
            end
            
        end % FindRequestAllAxes
        
        % Function: c =====================================================
        % Abstract:
        %
        % Find the signals (autoscale) for the specified axis.  If the y-limits of
        % this axis were changed updatedY will be true.  If the x-limits were changed
        % then updatedX will be true.  Note that the latter applies to all axes,
        % since it is required that the x scales of all axes be identical.
        
        function [updatedX, updatedY] = FindRequest( ...
                scopeUserData, simStatus, axesIdx)
            
            updatedY      = 0;
            updatedX      = 0;
            scopeAxes     = scopeUserData.scopeAxes;
            ax            = scopeAxes(axesIdx);
            axesUserData  = get(ax, 'UserData');
            block         = scopeUserData.block;
            scopeHiLite   = scopeUserData.scopeHiLite;
            
            if ishandle(scopeHiLite)
                %To make sure hiLiteVis is always a cell array (%g363813: see below)
                % we pass in a cell array of the property name(Visible)
                hiLiteVis = get(scopeHiLite,{'Visible'});
                set(scopeUserData.scopeHiLite,'Visible','off');
            end
            
            try %#ok no catch needed
                
                if ~strcmp(simStatus, 'stopped')
                    %
                    % Simulation is running.  Retrieve auto limits from block.
                    %
                    set_param(block, 'CurrentAxesIdx', axesIdx);
                    yLim = get_block_param(block, 'PlotLimits');
                    
                    %
                    % Handle degenerate cases.
                    %
                    if any(isinf(yLim)), return, end
                    
                    origYLim = get(ax, 'YLim');
                    loda     = yLim(1);
                    hida     = yLim(2);
                    
                    %
                    % In the case of min==max (a.k.a "PROBLEM # 1" in
                    % axrender.c/compute_axis_limits()), resolve by using
                    % hard defaults the same as compute_axis_limits().
                    %
                    if (loda==hida)
                        def_lim = [0.0, 1.0];
                        dlim    = def_lim(2) - def_lim(1);
                        yLim    = [ loda-dlim, hida+dlim ];
                    end
                    
                    %
                    % Protect the ylim with the same precision checks as the C-code used for
                    % for axes rendering. See axrender.c/CheckPrecisionOfLimits(), where
                    % we are preventing
                    %     if ( (hida - loda) < (precision * (fabs(hida) + fabs(loda))) ) {
                    % from being true. Note, the body of CheckPrecisionOfLimits() is slightly
                    % different than below ... the C code correction doesn't necessarily
                    % result in a range large enough to satisfy the said condition.
                    %
                    
                    precision = 1.e-10;
                    
                    allowableRange = (precision * (abs(hida) + abs(loda)));
                    
                    if ((hida - loda) < allowableRange)
                        mid    = (hida + loda)/2.0;
                        
                        allowableRange  = allowableRange * 1.1;
                        
                        hida   = mid + allowableRange/2;
                        loda   = mid - allowableRange/2;
                        
                        yLim = [loda hida];
                    end
                    
                    %
                    % Set the limits to the those stored by the block.
                    %
                    set(ax, 'YLim', yLim);
                    
                    %
                    % Since we are storing these limits as well as displaying them in
                    % the blocks dialog, we clean up the limits by using MATLAB's chosen
                    % tick positions.
                    %
                    yTick    = get(ax, 'YTick');
                    yTickDel = (yTick(end) - yTick(end-1)) / 2;
                    
                    %
                    % ...We know that the upper limit is set to accommodate the max value.
                    %    So, at this point, the data should all be equal to or less than
                    %    the upper limit.  If the highest tick mark is equal to the upper
                    %    limit, then the limit value is already a "nice" number.  If the
                    %    highest tick mark is less than the set limit, then we probably
                    %    don't have a "nice" number.  In that case, we clean it up as
                    %    follows:
                    %
                    if yTick(end) < yLim(2)
                        nDels   = ceil( (yLim(2) - yTick(end)) / yTickDel );
                        yLim(2) = yTick(end) + (yTickDel * nDels);
                    end
                    
                    %
                    % Same idea for the lower limit.
                    %
                    if yTick(1) > yLim(1)
                        nDels   = ceil( (yTick(1) - yLim(1)) / yTickDel );
                        yLim(1) = yTick(1) - (yTickDel * nDels);
                    end
                    
                    set(ax, 'YLim', yLim);
                    
                    if ~all(yLim == origYLim)
                        updatedY = 1;
                    end
                    
                    %
                    % Do auto scaling on the Time Limits.  The algorithm is as follows:
                    %   time range < simulation time span, then do nothing
                    %   time range > simulation time span, then timerange = time span
                    %
                    % Note that this is done to all axes in order to keep the time
                    % scales in sync.
                    %
                    simTimeSpan  = get_block_param(block, 'SimTimeSpan');
                    strTimeRange = Simulink.scopes.Util.GetTimeRange(block);
                    timeRange    = sscanf(strTimeRange, '%f');
                    
                    if ~strcmp(strTimeRange, 'auto') && (timeRange > simTimeSpan)
                        updatedX = 1;
                        set(scopeAxes, 'XLim', [0 simTimeSpan]); % all axes
                    end
                    
                    %
                    % Let the block and any open dialogs know about the new settings.
                    %
                    if updatedY,
                        newYLims = get(scopeAxes, 'YLim');
                        if iscell(newYLims)
                            newYLims = cat(1, newYLims{:});
                        end
                        Simulink.scopes.Util.SetBlockYLims(block, newYLims);
                        
                        %
                        % Let the axes property dialog know that a 'find' has occurred.
                        %
                        if ishandle(axesUserData.propDlg)
                            Simulink.scopes.Util.SyncAxPropertiesDialog(block, dialogUserData, axesIdx);
                        end
                        
                    end
                    
                    if updatedX,
                        strTRange = sprintf('%-16g', simTimeSpan);
                        set_param(block, 'TimeRange', strTRange);
                        
                        %
                        % Let the main property dialog know that a 'find' has occurred.
                        %
                        if ishandle(scopeUserData.scopePropDlg)
                            scpprop('FindCallBack', scopeUserData.scopePropDlg);
                        end
                    end
                    
                    %
                    % Update the line data.
                    %
                    scopeLineData = get_block_param(block, 'CopyDataBuffer');
                    Simulink.scopes.Util.ShiftNPlot(scopeUserData, scopeLineData, axesIdx);
                    
                else
                    %
                    % Simulation is not running.  Update the axes, but don't update the block
                    % settings.  This is considered a "data exploration" option and should not
                    % change how the block runs when the next sim starts.  This operation
                    % retrieve's all data from the block (if needed), and zeros out the time
                    % offset.
                    %
                    
                    % check for degenerate case
                    if ~Simulink.scopes.Util.BufferInUse(block)
                        return;
                    end
                    
                    % Another degenerate case
                    zoomable = false;
                    precision = eps;
                    nAxes    = length(scopeAxes);
                    for i=1:nAxes,
                        [validLines, hLines] = Simulink.scopes.Util.GetAxesLines(block,scopeAxes,i);
                        if validLines
                            nLines = length(hLines);
                            
                            %
                            % If not enough range for zoom, empty that line
                            %
                            for j=1:nLines,
                                h = hLines(j);
                                hXData = get(h,'XData');
                                rX= max(hXData) - min(hXData);
                                if rX < precision
                                    % set bad data to empty to avoid graphics crash
                                    set(hLines, 'Visible', 'off');
                                    set(h,'XData',[]);
                                    set(h,'YData',[]);
                                    set(hLines, 'Visible', 'on');
                                else
                                    % at least one line is zoomable
                                    zoomable = true;
                                end
                            end
                            
                        end
                    end
                    
                    if ~zoomable
                        return;
                    end;
                    
                    %
                    % Unshift the data (remove offset).  This must be done to all axes in
                    % order to keep their time bases in sync.
                    %
                    if (get_block_param(block, 'Offset') ~= 0)
                        updatedX = 1;
                        nAxes    = length(scopeAxes);
                        offset   = get_block_param(block, 'Offset');
                        for i=1:nAxes,
                            thisAx = scopeAxes(i);
                            [validLines, hLines] = Simulink.scopes.Util.GetAxesLines(block,scopeAxes,i);
                            
                            if validLines
                                nLines = length(hLines);
                                
                                set(hLines, 'Visible', 'off');
                                
                                %
                                % Shift the data.
                                %
                                for j=1:nLines,
                                    h = hLines(j);
                                    set(h, 'XData', get(h,'XData') + offset);
                                end
                                
                                set(thisAx, 'XLimMode','auto');
                                set(hLines, 'Visible', 'on');
                            end
                        end
                        
                        %
                        % Set offset value to zero.
                        %
                        if (ishandle(scopeUserData.timeOffset))
                            set(scopeUserData.timeOffset, 'String', '0');
                        end
                        set_param(block, 'Offset', 0.0);
                    end
                    
                    origYLim = get(ax, 'YLim');
                    set(ax, 'YLimMode', 'auto');
                    newYLim  = get(ax, 'YLim');
                    if ~all(origYLim == newYLim)
                        updatedY = 1;
                    end
                    
                    origXLim = get(ax, 'XLim');
                    set(ax, 'XLimMode', 'auto');
                    newXLim = get(ax, 'XLim');
                    if ~all(origXLim == newXLim)
                        updatedX = 1;
                        
                        %
                        % Make sure that all axes keep the same x-limits.
                        %
                        set(scopeAxes, 'XLim', newXLim);
                    end
                    
                    if ~strcmp(get_block_param(block, 'ZoomMode'), 'off') && (updatedX || updatedY)
                        scopezoom('reset', get_block_param(block,'Figure'));
                    end
                    
                    set(ax,'YLimMode','manual','XLimMode','manual');
                end
                
                %
                % Update the highlight rectangle for all axes.
                %
                simscope('ResizeHiLites', get_block_param(block,'Figure'));
            end
            
            % g363813
            if ishandle(scopeHiLite)
                set(scopeUserData.scopeHiLite,{'Visible'},hiLiteVis);
            end
        end % % Function: FindRequest
        
        
        % Function: CreatePrintFigure ===============================================
        % Abstract:
        %    Create a new invisible figure without buttons for printing
        
        function printFig = CreatePrintFigure(scopeFig,scopeUserData)
            
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            axesGeom  = Simulink.scopes.Util.CreateAxesGeom(scopeFig, scopeUserData);
            
            %
            % Compute axes positions as if there was no toolbar.
            %
            scopeUserData.toolGeom.height = 0; %change only local copy
            
            printFig = figure(...
                'HandleVisibility',   'off',...
                'IntegerHandle',      'off', ...
                'Visible',            'off',...
                'MenuBar',            'none', ...
                'NumberTitle',        'off',...
                'Position',           get(scopeFig, 'Position'), ...
                'Name',               get(scopeFig, 'Name'), ...
                'PaperUnits',         'inches');
            
            paperSize = get(printFig, 'PaperSize');
            paperPos  = [0.25 0.25 paperSize(1)-0.5 paperSize(2)-0.5];
            set(printFig, 'PaperPosition', paperPos, 'Units', 'normal');
            
            printAxes = copyobj(scopeAxes, printFig);
            
            fontSize = scopeUserData.axesFontSize;
            fontName = scopeUserData.axesFontName;
            
            for i=1:nAxes,
                printAx  = printAxes(i);
                hTitle   = get(scopeAxes(i), 'Title');
                titleStr = get(hTitle, 'String');
                
                if strcmp(get(hTitle, 'Visible'), 'on')
                    color    = get(hTitle, 'Color');
                    hTitle   = get(printAx, 'Title');
                    
                    set(hTitle, ...
                        'String',       titleStr,...
                        'FontName',     fontName, ...
                        'FontSize',     fontSize, ...
                        'Interpreter',  'none', ...
                        'Color',        color);
                end
            end
            
            set(printAxes, 'Units', 'normal');
            
            
            %
            % Create an invisible axes for placement of the time offset text.
            %
            pos    = get(printAxes(1), 'Position');
            pos(2) = 1;
            
            timeOffsetAxes = axes(...
                'Parent',       printFig, ...
                'Visible',      'off', ...
                'Units',        'pixel', ...
                'Position',     pos);
            
            tOffsetLabel = scopeUserData.timeOffsetLabel;
            tOffset      = scopeUserData.timeOffset;
            
            if ishandle(tOffsetLabel) && ishandle(tOffset)
                txtString  = [get(tOffsetLabel, 'String') ' ' get(tOffset, 'String')];
                
                tmpOffsetLabel = text(...
                    'Parent',         timeOffsetAxes, ...
                    'VerticalAlign',  'bottom', ...
                    'color',          get(scopeAxes(1), 'XColor'), ...
                    'Position',       [0 0 0], ...
                    'String',         txtString, ...
                    'FontName',       get(tOffsetLabel,'FontName'), ...
                    'FontSize',       get(tOffsetLabel,'FontSize'));
            end
            
        end % CreatePrintFigure
        
        % Function: PrintScopeWindow ================================================
        % Abstract:
        %    Print the scope window without the toolbar.
        
        function PrintScopeWindow(scopeFig, scopeUserData)
            
            printFig=Simulink.scopes.Util.CreatePrintFigure(scopeFig,scopeUserData);
            
            if ~isunix,
                printdlg(printFig);
            else
                h=printdlg(printFig);
                if ~isempty(h)
                    waitfor(h);
                end
            end
            
            delete(printFig);
            
        end % PrintScopeWindow
        
        % Function: ManageScopeBar ==================================================
        % Abstract:
        %    Manage callbacks from scope toolbar.
        function ManageScopeBar(scopeFig, buttonType, buttonAction)
            
            modified = false;
            scopeUserData = get(scopeFig, 'UserData');
                
            switch(buttonType)
                
                case 'ActionIcon',
                    
                    switch(buttonAction)
                        
                        case 'Find',
                            Simulink.scopes.Util.FindRequestAllAxes(scopeFig, scopeUserData);
                            
                        case 'Sync',
                            Simulink.scopes.Util.SyncAxesSettingsAll(scopeFig, scopeUserData);
                            
                        case 'Restore',
                            Simulink.scopes.Util.RestoreYLimits(scopeFig, scopeUserData);
                            
                        case 'Print',
                            Simulink.scopes.Util.PrintScopeWindow(scopeFig, scopeUserData);
                            
                        case 'PropDlg',
                            scpprop('create', scopeFig);
                            
                        case 'Float',
                            %
                            % Set floating scope state
                            %
                            actionIcons = scopeUserData.toolbar.children.actionIcons;
                            
                            setting = get(gcbo,'State');
                            %
                            % Set the scope's Floating parameter to the new
                            % setting and then activate the zoom buttons if
                            % possible.
                            %
                            
                            bd = scopeUserData.block_diagram;
                            
                            if ~Simulink.scopes.Util.IsSimActive(bd)
                                %
                                % Only transition to enable if simulation is stopped.
                                %
                                set_param(scopeUserData.block, 'Floating', setting);
                                if strcmp(setting, 'off')
                                    %
                                    % Check the selection data, to make sure it is consistent.
                                    % This should not be necessary, but it will throw a warning
                                    % and fix discrepencies if something is wrong.
                                    %
                                    Simulink.scopes.Util.RestorePortConnections(scopeUserData.block);
                                    
                                    %
                                    % Delete any signal selectors because they are not valid
                                    % for wired scopes.
                                    %
                                    signalselector('Delete', scopeUserData.block);
                                end
                                
                                %
                                % Manage buttons and THEN redraw axes (axes key off of
                                % lock state set by lockdown mode).
                                %
                                Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
                                scopebar(scopeFig, 'SelectButton', setting);
                                
                                [modified, scopeUserData] = Simulink.scopes.Util.UpdateAxesConfig(scopeFig, scopeUserData);
                                
                                % Enable zoom buttons if not floating scope
                                if strcmp(setting, 'off')
                                    Simulink.scopes.Util.SetEnableForNonRunWithData(scopeFig, scopeUserData);
                                end
                                
                                %
                                % Selection Data needs to be re-loaded here, because 'UserData'
                                % stored in the axes keeps handles to lines, and these handles
                                % can change as lines are connected/disconnected from the scope.
                                % E.G. Mux output lines that are disconnected from a scope and
                                % reconnected above may get destroyed and recreated with new
                                % handles.
                                %
 
                            end
                            
                        case 'LockAxes',
                            %
                            % Set the lock button tooltip
                            %
                            newState = get(gcbo, 'State');
                            scopebar(scopeFig, 'LockButton', 'on', newState);
                            
                            if strcmp(newState, 'off')
                                %
                                % First, grab focus from all other scopes,
                                % then manage this scope's lockdown.
                                %
                                Simulink.scopes.Util.GrabWirelessScopeFocus(scopeFig);
                                simscope('SelectedAxes', 'Dialog', scopeFig);
                            else
                                Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
                            end
                            
                        case 'Select',
                            simscope('SelectedAxes', 'Dialog', scopeFig);
                            scopeUserData = get(scopeFig, 'UserData');
                            currAxesIdx   = get_block_param(scopeUserData.block, 'SelectedAxesIdx');
                            signalselector('Create', 'simscope', ...
                                scopeUserData.block, ...
                                str2num(get_block_param(scopeUserData.block, 'NumInputPorts')), ...
                                currAxesIdx, ...
                                DAStudio.message('Simulink:blocks:ScopeAxes'), ...
                                1,...  % Allow multiple selections
                                Simulink.scopes.Util.SignalSelectorTitle(scopeUserData.block));
                            
                        otherwise,
                            DAStudio.error('Simulink:blocks:UnexpectedButtonAction');
                    end
                    
                otherwise,
                    DAStudio.error('Simulink:blocks:UnexpectedButtonType');
            end
            
            if (modified)
                set(scopeFig, 'UserData', scopeUserData);
                
            end
            
        end % ManageScopeBar
        
        % Function: CreateLinesForAxes =======================================
        % Abstract:
        %
        % Create lines for the current axes of the current scope block. 
        % This sets up the current axes on the block
        %
        function newLines = CreateLinesForAxes(block,scopeUserData, axIdx)
            
           
            if ~feature('useHG2')
                newLines = Simulink.scopes.Util.hg1CreateLinesForAxes( ...
                    block, scopeUserData, axIdx);
                return;
            end
            
            block = scopeUserData.block;
            
            %HD should just get this info from the axes
            set_param(block, 'CurrentAxesIdx', axIdx);
            numLinesNeeded = get_block_param(block, 'NumLinesNeeded');
            if isempty(numLinesNeeded)
                newLines = [];
                return;
            end
            
            lineStyleIdxs  = get_block_param(block, 'LineStyleIndices');
            nSigs = length(numLinesNeeded);
            ax    = scopeUserData.scopeAxes(axIdx);
            
            lineStyleOrder = scopeUserData.lineStyleOrder;
            colorOrder     = get(ax,'ColorOrder');
            nColors        = length(colorOrder);
            
            %
            % Create the lines.
            %
            newLines = cell(1,nSigs);
            for sigIdx=1:nSigs,
                numLines = numLinesNeeded(sigIdx);
                if (numLines ~= 0)
                    % TODO pre-alloc the lines if performance needed
                    colorIdx  = 1;
                    lineStyle = lineStyleOrder{lineStyleIdxs(sigIdx)};
                    
                    for i=1:numLines,
                        color = colorOrder(colorIdx,:);
                       
                        lines(i) = feval('hg2sample.LineAnimator');
                        set(lines(i), 'Parent', ax, ...
                            'Color', color, ...
                            'LineStyle', lineStyle, ...
                            'Tag', 'ScopeLine');
                        
                        colorIdx = colorIdx + 1;
                        if (colorIdx > nColors)
                            colorIdx = 1;
                        end
                    end
                    newLines{sigIdx} = lines;
                end
            end
            
            
        end % CreateLinesForAxes
        
        % Function: GrabWirelessScopeFocus ==========================================
        % Abstract:
        %    Make this scope the one with the blue rectangle in an axes.
        %
        function scopeFigFocusChanged = GrabWirelessScopeFocus(scopeFig)
            scopeUserData  = get(scopeFig, 'UserData');
            scopeBlockName = getfullname(scopeUserData.block);
            
            oldScope       = get_block_param(scopeUserData.block_diagram,'FloatingScope');
            
            scopeFigFocusChanged = 0;
            if ~isempty(oldScope)
                oldScopeFig      = get_param(oldScope, 'Figure');
                oldScopeUserData = get(oldScopeFig, 'UserData');
                if ~strcmp(scopeBlockName,oldScope)
                    scopeFigFocusChanged = 1;
                    Simulink.scopes.Util.SetWirelessScopeLockdownMode(oldScopeUserData, 'on');
                end
            else
                scopeFigFocusChanged = 1;
            end
            
            if scopeFigFocusChanged,
                set_param(scopeUserData.block_diagram, 'FloatingScope', scopeBlockName);
            end
            
            scopebar(scopeFig, 'LockButton', 'on', 'off');
            
        end % GrabWirelessScopeFocus
        
        % Function: DeleteAxesHiLite ================================================
        % Abstract:
        %    Delete any rectangles in the axes.  Robust to axes that don't have
        %    highlighting rectangles.
        %
 %       function hiLiteHandle = DeleteAxesHiLite(axesHandle)
         function  DeleteAxesHiLite(axesHandle)
            %
            % Delete any existing rectangles in the axes
            %
            
            axesChildren = get(axesHandle, 'Children');
            if ~isempty(axesChildren)
                rectHandleList = strmatch('rectangle', get(axesChildren, 'Type'));
                if ~isempty(rectHandleList)
                    delete(axesChildren(rectHandleList));
                end
            end
            
        end % DeleteAxesHiLite
        
        % Function: CreateAxesHiLite ================================================
        % Abstract:
        %
        % Create the highlighting rectangle used to highlight the selected axes
        % of a wireless scope.  The rectangle will be invisible when the axes
        % is not the selected axes and a color (blue) when selected and the figure
        % is not locked down.
        %
        function hiLiteHandle = CreateAxesHiLite(scopeFig, axesHandle, tLim, yLim)
            
            hiLiteCallback = 'simscope(''AxesClick'')';
            %
            % install a callback to allow selection of
            % axes (Note: this also undoes a "lockdown")
            %
            set(scopeFig, 'CurrentAxes', axesHandle);
            set(axesHandle, 'ButtonDownFcn', hiLiteCallback);
            
            %
            % Delete any existing highlighting rectangles
            %
            Simulink.scopes.Util.DeleteAxesHiLite(axesHandle);
            
            % Make a highlighting rectangle on the axes
            % NOTE: only the 'inner' half of 'linewidth' is visible
            if tLim(2) == Inf
                tRange = 10; % NOTE: Simulink.scopes.Util.ComputeSimulationTimeSpan() seems inconsistent
            else
                tRange = tLim(2);
            end
            
            hiLiteHandle = rectangle(...
                'Parent',    axesHandle, ...
                'Position', [0, yLim(1), tRange, yLim(2)-yLim(1)], ...
                'LineWidth', 8, ...
                'FaceColor', 'none', ...
                'EdgeColor', 'none', ...
                'ButtonDownFcn', hiLiteCallback);
            
        end % CreateAxesHiLite
        
        % Function: HiLiteOn ========================================================
        % Abstract:
        %    Make the axes HiLite visible.
        %
        function HiLiteOn(scopeUserData,ax)
            
            if ishandle(scopeUserData.scopeHiLite(ax))
                set(scopeUserData.scopeHiLite(ax),'EdgeColor','blue');
            end
            
        end % HiLiteOn
        
        % Function: HiLiteOff =======================================================
        % Abstract:
        %    Make the axes HiLite invisible.
        %
        function HiLiteOff(scopeUserData,ax)
            
            if ishandle(scopeUserData.scopeHiLite(ax))
                set(scopeUserData.scopeHiLite(ax),'EdgeColor','none');
            end
            
        end % HiLiteOff
        
        
        % Function: HiLiteResize ====================================================
        % Abstract:
        %    Resizes the HiLite given the new X axes limits and new Y axes limits.
        %
        function HiLiteResize(scopeUserData, ax, xLim, yLim)
            
            if ishandle(scopeUserData.scopeHiLite(ax))
                set(scopeUserData.scopeHiLite(ax), 'Position',...
                    [xLim(1), yLim(1), xLim(2)-xLim(1), yLim(2)-yLim(1)]);
            end
            
        end% HiLiteResize
        
        
        
        % Function: SetWirelessScopeLockdownMode ====================================
        % Abstract:
        %    Set the blue pick focus for a given wireless scope and sync the
        %    lock button state on the toolbar.
        %
        %    First Input argument is scopeUserData, but not necessarily from 'this'
        %    scope.
        %
        %    XXX rdavis: This may not need to be called for model-based scopes at all.
        %                I thought it was necessary to set up the signal selector.
        %
        function SetWirelessScopeLockdownMode(scopeUserData, state)
            
            floating   = slprivate('onoff',get_block_param(scopeUserData.block, 'Floating'));
            modelBased = Simulink.scopes.Util.IsModelBased(scopeUserData.block);
            
            set_param(scopeUserData.block, 'LockDownAxes', state);
            %
            % Turn off any existing highlighting to show that the axes
            % are no longer selected.
            %
            selectedAxes = get_block_param(scopeUserData.block,'SelectedAxesIdx');
            if ((floating || modelBased) && ...
                    ishandle(scopeUserData.scopeHiLite(selectedAxes)))
                if (slprivate('onoff',state))
                    Simulink.scopes.Util.HiLiteOff(scopeUserData,selectedAxes);
                else
                    Simulink.scopes.Util.HiLiteOn(scopeUserData,selectedAxes);
                end
                
                % figure has re-rendered - invalidate the blit buffer
                get_block_param(scopeUserData.block, 'InvalidateBlitBuffer');
            end
            
            %
            % Set the lock button state on the toolbar if floating
            %
            scopeFig = get_block_param(scopeUserData.block, 'Figure');
            enabledness = get_block_param(scopeUserData.block, 'Wireless');
            if ~modelBased
                if strcmp(enabledness, 'off')
                    lockButtonState = 'off';
                else
                    lockButtonState = state;
                end
                scopebar(scopeFig, 'LockButton', enabledness, lockButtonState);
            end
            
        end % SetWirelessScopeLockdownMode
        
        
        % Function: IsSimActive =====================================================
        % Abstract:
        %    Return 1 if simulation is running or paused or in active external mode.
        function simIsActive = IsSimActive(hMdl)
            
            simStatus = Simulink.scopes.Util.SimpleSimStatus(hMdl);
            
            if strcmp(simStatus,'stopped')
                simIsActive = 0;
            else
                simIsActive = 1;
            end
            
        end % isSimActive
        
        
        % Function: RestorePortConnections ==========================================
        % Abstract:
        %    If there are line segments adjacent to unconnected ports on the scope,
        %    reconnect them as long as we are allowed to change the block diagram.
        %
        function RestorePortConnections(scope)
            
            portHandles = get_block_param(scope,'PortHandles');
            inHandles   = portHandles.Inport;
            
            for k=1:length(inHandles)
                if ~ishandle(get_param(inHandles(k),'Line')) && ~Simulink.scopes.Util.IsSimActive(bdroot(scope))
                    portCoords = get_param(inHandles(k), 'Position');
                    newLineHandle = add_line(get_param(scope, 'Parent'), ...
                        [portCoords; portCoords]);
                    if ~ishandle(get_param(newLineHandle, 'SrcPortHandle'))
                        delete_line(newLineHandle);
                    end
                end
            end
            
        end % RestorePortConnections
        
        % Function: SignalSelectorTitle ==============================================
        % Abstract:
        %   Returns a title to be used in the signal selector dialog box.
        %
        function title = SignalSelectorTitle(block)
            if Simulink.scopes.Util.IsModelBased(block)
                title = viewertitle(block, true);
            else
                title = getfullname(block);
            end
            
        end % SignalSelectorTitle
        
        
        % Function: SIG_SEP ===========================================================
        % Abstract:
        %    Constant function for a signal separator, scoped to this file.
        %
        function str = SIG_SEP
            str = '|';
            
        end
        % Function: PORT_SEP ==========================================================
        % Abstract:
        %    Constant function for a port separator, scoped to this file.
        %
        function str = PORT_SEP
            str = ':';
            
        end
        
        % Function: ParseSelectionData ===============================================
        % Abstract:
        %    Get the SelectedSignals saved in the block.
        %
        function signals = ParseSelectionData(block)
            
            try  %Added for safety since errors here will cause models to NOT load
                data          = get_block_param(block, 'SelectedSignals');
                if isempty(data)
                    signals = {[]};
                    return;
                end
                
                numDataAxes = length(fieldnames(data));
                
                signals = cell(numDataAxes,1);  %pre-allocate cell array
                for i = 1:numDataAxes
                    sigList      = eval(['data.axes' num2str(i)]);
                    
                    % if the siglist is empty, continue.  The code below doesn't
                    % work correctly if there are no signals.
                    if isempty(sigList)
                        continue;
                    end
                    
                    % Create a cell array with one element for each signal.
                    sigCell      = eval(['{''' strrep(sigList, SIG_SEP, ''',''') '''}']);
                    signals{i}(length(sigCell)) = 0;  %pre-allocate line list
                    badSigs = 0;
                    for j = 1:length(sigCell)
                        sig = sigCell{j};
                        if isempty(sig)
                            badSigs = badSigs + 1;
                            continue;
                        end
                        idx = find(sig == PORT_SEP);
                        blk = sig(1:idx(end)-1);
                        
                        % Get the block Handle
                        try
                            blkH = get_block_param(blk, 'Handle');
                        catch me %#ok<NASGU>
                            try
                                % If an error occurred, it may have been caused by a block name change.
                                % Use the current name of the block and try again.  Looking for the
                                % first '/' in the block name suffices for finding the old bdroot,
                                % because '/' is not a valid character in filenames.
                                idx2 = find(blk == '/');
                                bdName = get_param(bdroot(block),'Name');
                                blk = [bdName blk(idx2(1):end)];
                                blkH = get_block_param(blk, 'Handle');
                            catch me %#ok<NASGU>
                                % If an error occurred here, then the block is truly invalid.  Punt.
                                badSigs = badSigs + 1;
                                continue;
                            end
                        end
                        
                        port = str2num(sig(idx(end)+1:end));
                        portHs   = get_block_param(blkH, 'PortHandles');
                        ports    = cat(2, portHs.Outport, portHs.State);
                        sig_port = ports(port);
                        sig_line = get_param(sig_port, 'Line');
                        if ishandle(sig_line)
                            signals{i}(j-badSigs) = sig_line;
                        else
                            badSigs = badSigs + 1;
                        end
                    end
                    %Trim the list if some elements were invalid.
                    if (badSigs > 0)
                        signals{i} = signals{i}(1:length(sigCell)-badSigs);
                    end
                end
            catch me %#ok<NASGU>
                signals = {};
                DAStudio.warning('Simulink:blocks:DataParsingError');
            end  %Added for safety since errors here will cause models to NOT load
            
        end % ParseSelectionData

        % Function: UpdateSelectionDataNumAxes ======================================
        % Abstract:
        %    Change the selection data to remove data for axes that are eliminated or
        % add empty arrays for axes that are added.  This function was added because it
        % became important to keep the selection data tightly synchronized with the
        % selected signal information in the axes.
        %
        function UpdateSelectionDataNumAxes(block, newNumAxes)
            
            try  %Added for safety since errors here will cause models to NOT load
                oldData    = get_block_param(block, 'SelectedSignals');
                newData    = [];
                
                % Read this value from the Saved Data.  This is important, because when the
                % axes are first created, the old number of axes will be inconsistent with
                % what is saved in 'SelectedSignals'.
                if isempty(oldData)
                    oldNumAxes = 0;
                else
                    oldNumAxes = length(fieldnames(oldData));
                end
                
                % Move the data over for each axis that still exists, and add empty
                % data for new axes.
                for i = 1:newNumAxes
                    if (i<=oldNumAxes)
                        eval(['newData.axes' num2str(i) '= oldData.axes' num2str(i) ';']);
                    else
                        eval(['newData.axes' num2str(i) '= '''';']);
                    end
                end
                
                % Set the SelectedSignals field
                set_param(block, 'SelectedSignals', newData);
            catch
                DAStudio.warning('Simulink:blocks:DataUpdateError');
            end  %Added for safety since errors here will cause models to NOT load
            
        end % UpdateSelectionDataNumAxes
        
        % Function: GetSelection ====================================================
        % Abstract:
        %    Return port selection
        %
        function ports = GetSelection(block, axesIdx)
            
            scopeFig      = get_block_param(block, 'Figure');
            scopeUserData = get(scopeFig, 'UserData');
            
            % Set the selected axes
            set(scopeFig, 'CurrentAxes', scopeUserData.scopeAxes(axesIdx));
            simscope('SelectedAxes', 'Dialog', scopeFig);
            
            % Determine lines
            axUserData = get(scopeUserData.scopeAxes(axesIdx),'UserData');
            lines      = axUserData.signals;
            ports      = get_param(lines, 'SrcPortHandle');
            if iscell(ports)
                ports = [ports{:}]';
            end
            
        end % GetSelection
        
        % Function: AddSelection ====================================================
        % Abstract:
        %    Add ports to selection list.
        %
        function AddSelection(block, ax, ports)
            
            %
            % Select lines and children.
            %
            lines = get_param(ports, 'Line');
            if iscell(lines)
                lines = [lines{:}]';
            end
            
            for i = 1:length(lines)
                if (lines(i) > 0)
                    set_param(lines(i), 'Selected', 'on')
                end
            end
            
            %
            % Add entries to IOSignals.  If this axes is the 'blue one', then the
            % act of selecting the lines takes care of setting up the iosigs.
            %
            ioSigs   = get_block_param(block,'IOSignals');
            ioSigs   = Simulink.scopes.Util.RemoveInvalHandles(ioSigs,ax);
            axIOSigs = ioSigs{ax};
            
            for i=1:length(ports)
                hp = ports(i);
                if ishandle(hp)
                    axIOSigs(end+1) = struct('Handle',hp,'RelativePath','');
                end
            end
            [~,i,j] = unique([axIOSigs.Handle]);
            axIOSigs = axIOSigs(i);
            ioSigs{ax} = axIOSigs;
            set_param(block,'IOSignals',ioSigs);
            
        end % AddSelection
        
        
        % Function: DeselectLinesAndChildren ========================================
        % Abstract:
        %
        function DeselectLinesAndChildren(line)
            
            set_param(line, 'Selected', 'off');
            children = get_param(line, 'LineChildren');
            if iscell(children)
                children = [children{:}]';
            end
            for j = 1:length(children)
                Simulink.scopes.Util.DeselectLinesAndChildren(children(j));
            end
            
        end % DeselectLinesAndChildren
        
        % Function: RemoveSelection =================================================
        % Abstract:
        %    Remove ports from selection list.
        %
        function RemoveSelection(block, ax, ports)
            
            %
            % Deselect lines and children
            %
            lines = get_param(ports, 'Line');
            if iscell(lines)
                lines = [lines{:}]';
            end
            
            for i = 1:length(lines)
                % Do set_param only for valid lines
                if (lines(i) > 0)
                    Simulink.scopes.Util.DeselectLinesAndChildren(lines(i));
                end
            end
            
            %
            % Prune out appropriate entries from IOSignals
            %
            ioSigs   = get_block_param(block,'IOSignals');
            %ioSigs   = Simulink.scopes.Util.RemoveInvalHandles(ioSigs);
            axIOSigs = ioSigs{ax};
            
            for i=1:length(ports)
                hp = ports(i);
                if ishandle(hp)
                    axIOSigs([axIOSigs.Handle] == hp) = [];
                end
            end
            ioSigs{ax} = axIOSigs;
            set_param(block,'IOSignals',ioSigs);
            
        end % RemoveSelection
        
        
        % Function: SwitchSelection =================================================
        % Abstract:
        %    Switch the selection from one port to another.
        %
        function SwitchSelection(block, ax, oldPort, newPort)
            scopeFig      = get_block_param(block, 'Figure');
            scopeUserData = get(scopeFig, 'UserData');
            
            % Get axes user data of the relevant axes
            axUserData = get(scopeUserData.scopeAxes(ax), 'UserData');
            
            if (oldPort ~= INVALID_HANDLE)
                %% Deselect line and children
                oldLine = get_param(oldPort, 'Line');
                
                % Do set_param only for valid lines
                if (oldLine > 0)
                    Simulink.scopes.Util.DeselectLinesAndChildren(oldLine);
                    
                    % Remove this from the userdata
                    idx = find(axUserData.signals == oldLine);
                    if ~isempty(idx)
                        axUserData.signals(idx) = [];
                    end
                end
            end
            
            if (newPort ~= INVALID_HANDLE)
                newLine = get_param(newPort, 'Line');
                
                % Do set_param only for valid lines
                if (newLine > 0)
                    set_param(newLine, 'Selected', 'on')
                    
                    % Add this to the userdata
                    if isempty(find(axUserData.signals == newLine))
                        axUserData.signals(end+1) = newLine;
                    end
                end
            end
            
            % Update axes userdata
            set(scopeUserData.scopeAxes(ax), 'UserData', axUserData);
            set(scopeFig, 'UserData', scopeUserData);
            
            
        end % SwitchSelection
        
        % Function: DialogClosing ===================================================
        % Abstract:
        %    Signal Selector Dialog is closing, so lock down axes
        %
        function DialogClosing(block)
            
            scopeFig = get_block_param(block, 'Figure');
            
            if ishandle(scopeFig)
                scopeUserData = get(scopeFig, 'UserData');
            else
                % Quietly ignore requests to Lock down invalid figure handles
                return;
            end
            
            Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
            
        end % DialogClosing
        
        function out = IsModelBased(block)
            ioType = get_block_param(block,'IOType');
            out   = strcmp(ioType,'viewer');
            
        end
        
        function ioSigsCell = RemoveInvalHandles(ioSigsCell,ax)
            ioSigsCell{ax}([ioSigsCell{ax}.Handle] == -1) = [];
        end
        
        %
        %
        %
        function scopeUserData  = ChangeBlueAxes(scopeFig,scopeUserData,axH)
            
            %
            % Received a callback request to change the Selected Axes
            % (and its index).  The Callback that calls this entry point
            % is installed only for wireless scopes.
            %
            
            modelBased = Simulink.scopes.Util.IsModelBased(scopeUserData.block);
            
            %
            % Turn off focus at previous wireless scope and set 'this'
            % scope to be the current scope in focus.
            %
            scopeFigFocusChange = Simulink.scopes.Util.GrabWirelessScopeFocus(scopeFig);
            
            ax  = find(scopeUserData.scopeAxes == axH);
            if isempty(ax)
                ax = 1;
            end
            ax = ax(1);
            oldAxes = get_block_param(scopeUserData.block,'SelectedAxesIdx');
            %
            % set the new axes immediately to avoid stale state farther down.
            %
            set_param(scopeUserData.block, 'SelectedAxesIdx', ax);
            scopeLockedDown = slprivate('onoff',get_block_param(scopeUserData.block, 'LockDownAxes'));
            
            %
            % If this is a model-based scope, the highlight needs to
            % change whenever the 'SelectedAxesIdx' changes.
            %
            if modelBased && ~Simulink.scopes.Util.IsSimActive(scopeUserData.block_diagram)
                Simulink.scopes.Util.HiLiteOff(scopeUserData,oldAxes);
                Simulink.scopes.Util.HiLiteOn(scopeUserData,ax);
            end
            
            %
            % Highlight the selected axes, either via axes selection
            % or via removal of a LockDown on this scope.
            %
            if (ax ~= oldAxes || scopeFigFocusChange || scopeLockedDown )
                %
                % Set the lockdown mode
                %
                Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'off');
                
                if ~modelBased
                    if ~ishandle(scopeUserData.scopeHiLite(ax))
                        simscope('PropDialogApply', scopeFig);
                        scopeUserData = get(scopeFig, 'UserData');
                    end
                    Simulink.scopes.Util.HiLiteOn(scopeUserData,ax);
                end
                
                if scopeLockedDown
                    set_param(scopeUserData.block, 'LockDownAxes', 'off');
                else
                    if ~modelBased
                        Simulink.scopes.Util.HiLiteOff(scopeUserData,oldAxes);
                    end
                end
                
                %
                % Cache the ioSigs for this axes (the clearing of the lines that
                % follows will wipe out this info.
                %
                sigHandles = get_block_param(scopeUserData.block,'IOSignals');
                
                %
                % Clear the set lines in the block diagram.
                % Then, set the previous lines in the block diagram
                % for this axes.
                %
                hLines = find_system(scopeUserData.block_diagram, 'findall', 'on', ...
                    'type', 'line', 'selected', 'on');
                for k=1:length(hLines)
                    set_param(hLines(k),'selected','off');
                end
                
                %
                % Reselect the signals of interest (the changing of the 'selected' prop
                % on the lines should re-establish the ioSigs - UGLY!).
                %
                sigHandles = sigHandles{ax};
                for k=1:length(sigHandles)
                    handle    = sigHandles(k).Handle;
                    mdlRefStr = sigHandles(k).RelativePath;
                    if ishandle(handle) && strcmp(mdlRefStr,'')
                        line = get_param(handle,'Line');
                        if ishandle(line)
                            set_param(line,'selected','on');
                        end
                    end
                end
                
                % figure has re-rendered - invalidate the blit buffer
                get_block_param(scopeUserData.block, 'InvalidateBlitBuffer');
                
            end
        end % ChangeBlueAxes
        
        
        function tRange = GetTimeRange(block)
            
            bd = bdroot(block);
            
            if slprivate('onoff',get_block_param(block,'Floating'))
                param = 'OverrideFloatScopeTimeRange';
            else
                param = 'OverrideScopeTimeRange';
            end
            tRange = get_param(bd, param);
            if isnan(tRange),
                tRange = get_block_param(block, 'TimeRange');
            else
                tRange = num2str(tRange);
            end
        end % GetTimeRange
        
        function msg = lclMessage(ID, varargin)
            
            msg = DAStudio.message(['Simulink:blocks:' ID], varargin{:});
            
        end % lclMessage
        
        % [EOF] Simulink.scopes.Util.m
        
   
        function  scopeUserData =  SetNumPorts(scopeBlk, newNumber)
            
            set_param(scopeBlk, 'NumInputPorts', newNumber);
            scopeFig = get_block_param(scopeBlk, 'Figure');
            
            if ishandle(scopeFig)
                scopeUserData = get(scopeFig, 'UserData');
                
                [modified, scopeUserData] = Simulink.scopes.Util.UpdateAxesConfig(scopeFig, scopeUserData);
                if (modified)
                    set(scopeFig, 'UserData', scopeUserData);
                end
                Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
            end
        end % SetNumPorts
        
        function PropDialogApply(scopeFig)
            
            scopeUserData = get(scopeFig, 'UserData');
            floatingStr   = get_block_param(scopeUserData.block, 'Floating');
            floating      = strcmp(floatingStr, 'on');
            modelBasedStr = get_block_param(scopeUserData.block, 'ModelBased');
            modelBased    = Simulink.scopes.Util.IsModelBased(scopeUserData.block);
            wirelessStr   = get_block_param(scopeUserData.block, 'Wireless');
            wireless      = strcmp(wirelessStr, 'on');
            bd            = scopeUserData.block_diagram;
            
            if Simulink.scopes.Util.IsSimActive(bd)
                simStatus = 'running';
            else
                simStatus = 'stopped';
            end
            
            if floating,
                scopezoom('off', scopeFig);
                scopebar(scopeFig, 'CtrlUI', simStatus);
            end
            
            if ~wireless,
                Simulink.scopes.Util.RestorePortConnections(scopeUserData.block);
            end
            
            [modified, scopeUserData] = Simulink.scopes.Util.UpdateAxesConfig(scopeFig, scopeUserData);
            if (modified)
                set(scopeFig, 'UserData', scopeUserData);
            end
            
            %
            % Sync toolbar floating-related buttons with
            % new dialog selections.  Float button exists
            % if not 'ModelBased' (i.e. the 'Signal Viewer
            % Scope').
            %
            if ~Simulink.scopes.Util.IsSimActive(bdroot(scopeUserData.block)) && ~modelBased,
                scopebar(scopeFig, 'FloatButton', 'on', floatingStr);
            end
            
            %
            % We need to reload 'SelectedSignals' into the Axes user data here,
            % because the axes may have changed, and signals will need to be
            % reloaded.  The Port Handles will need updating, too.

        end % PropDialogApply
        
        %
        % GetAxesLines as an array via C++, HG only
        %
        function [validLines, hLines] = hg1GetAxesLines(block,idx)

        set_param(block,'CurrentAxesIdx',idx);
            hLines = get_block_param(block,'AxesLineHandles');
            
            % Convert hLines to a regular array if it is a cell array
            if ~(isempty(hLines) || (all(hLines{:} == -1)))
                hLines = [hLines{:}];
                validLines = true;
            else
                validLines = false;
            end
        end % GetAxesLines
        
        %
        % GetAxesLines as an array from figure itself
        % Order of lines returned is not order of creation
        %
        function [validLines, hLines] = GetAxesLines(block,axes,idx)
        if ~feature('useHG2')
            [validLines, hLines] = Simulink.scopes.Util.hg1GetAxesLines(block,idx);
            return;
        end

        hLines = findobj(axes(idx), 'Tag','ScopeLine');

            % hLines will be an array
            if ~(isempty(hLines) || (all(hLines(:) == -1)))
                validLines = true;
            else
                validLines = false;
            end
        end % hg2GetAxesLines
        
 % Functions for HG2 conversion
 % =================================================

        function ax = hg1SetAxes(ax)
            if  ~feature('useHG2')
                set( ax,'Busy', 'queue');
                set( ax,'DrawMode','fast');
            end
        end
    
        function ax = hg1SetFigure(fig)
            if  ~feature('useHG2')
                set( fig, 'BackingStore', 'on');
            end
        end


        function newLines = hg1CreateLinesForAxes(block, scopeUserData, axIdx)
            
            set_param(block, 'CurrentAxesIdx', axIdx);
            numLinesNeeded = get_block_param(block, 'NumLinesNeeded');
            if isempty(numLinesNeeded)
                newLines = [];
                return;
            end
            
            lineStyleIdxs  = get_block_param(block, 'LineStyleIndices');
            nSigs = length(numLinesNeeded);
            ax    = scopeUserData.scopeAxes(axIdx);
            
            lineStyleOrder = scopeUserData.lineStyleOrder;
            colorOrder     = get(ax,'ColorOrder');
            nColors        = length(colorOrder);
            
            %
            % Create the lines.
            %
            newLines = cell(1,nSigs);
            for sigIdx=1:nSigs,
                numLines = numLinesNeeded(sigIdx);
                if (numLines ~= 0)
                    lines(numLines) = 0; %pre-alloc
                    colorIdx  = 1;
                    lineStyle = lineStyleOrder{lineStyleIdxs(sigIdx)};
                    
                    for i=1:numLines,
                        color = colorOrder(colorIdx,:);
                        
                        lines(i) = line(...
                            'Parent',         ax, ...
                            'Color',          color, ...
                            'LineStyle',      lineStyle, ...
                            'XData',          [nan,nan], ...
                            'YData',          [nan,nan], ...
                            'UIContextMenu',  get(ax,'UIContextMenu'),...
                            'Tag', 'ScopeLine', ...
                            'EraseMode',      'none');
                        
                        colorIdx = colorIdx + 1;
                        if (colorIdx > nColors)
                            colorIdx = 1;
                        end
                    end
                    newLines{sigIdx} = lines;
                end
            end
            
            
        end % CreateLinesForAxes
    end % methods
    
end % classdef Util

% Function: INVALID_HANDLE ====================================================
% Abstract:
%    A method to generate an invalid handle that appears "static" to this file.
%
function h = INVALID_HANDLE
    h = (-1);
end

% Function: GET_BLOCK_PARAM ====================================================
% Abstract:
%    Single entry point to C++ block code
function p = get_block_param(block, param)
    p = get_param(block,param);
end


% Function: UIWIDTH =========================================================
% Abstract:
% Compute extent of text control in characters
% For English, this extent is the number of characters in the string
% For Japanese, this extent is more than the number of characters in the
% string, as each string character is wider than 1.
function c = uiwidth(hExtentControl, string)
set(hExtentControl, 'String', string);
c = get(hExtentControl, 'Extent');
c = c(3);
end

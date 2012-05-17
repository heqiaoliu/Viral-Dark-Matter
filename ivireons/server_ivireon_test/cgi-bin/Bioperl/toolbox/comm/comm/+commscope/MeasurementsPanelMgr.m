classdef MeasurementsPanelMgr < commscope.InfoPanelMgr
    %MeasurementsPanelMgr Construct a measurements panel manager for EyeScope
    %
    %   Warning: This undocumented function may be removed in a future release.

    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:17:46 $

    %===========================================================================
    % Private properties
    properties (Access = private)
        SelectedIndices     % A binary vector to determine measurements
                            % displayed in the figure and the table
        CompareTableData    % Structure to store comparison table data
    end

    %===========================================================================
    % Public methods
    methods
        function this = MeasurementsPanelMgr
            % Set the default panel content indeices and create list
            this.DefaultPanelContentIndices = [12 13 14 15 16 17 8 18 19 9];
            createList(this);
            this.SelectedIndices = getDefaultSelectedIndices(this);
        end
        %-----------------------------------------------------------------------
        function reset(this)
            reset@commscope.InfoPanelMgr(this);
            this.SelectedIndices = getDefaultSelectedIndices(this);
        end
        %-----------------------------------------------------------------------
        function updateSelected(this, indices, value)
            this.SelectedIndices(this.PanelContentIndices(indices(1))) = value;
        end
        %-----------------------------------------------------------------------
        function tableData = prepareSelectedTableData(this)
            % Get the selected items list
            list = this.ContentsList(this.PanelContentIndices);
            screenNames = cell(length(list),1);
            [screenNames{:}] = deal(list(:).ScreenName);

            % Get the displayed items list
            displayed = ...
                num2cell(this.SelectedIndices(this.PanelContentIndices));

            % Generate data
            tableData = reshape({displayed{:} screenNames{:}}, length(list), 2);
        end
        %-----------------------------------------------------------------------
        function [tableData columnLabels me] = prepareTableData(this, eyeStr)
            %PREPARETABLEDATA Prepare eye measurements table data
            %   [TABLEDATA COLUMNLABELS] = PREPARETABLEDATA(THIS, HEYE)
            %   prepares a cell matrix table to use as an input to the table
            %   object for the eye diagram object settings panel.  EYESTR is an
            %   eye diagram object structure.

            if isempty(eyeStr)
                hEye = [];
            else
                hEye = eyeStr.Handle;

                if ~isempty(hEye)
                    % Update analysis results
                    me = updateAnalysisResults(hEye);
                end
            end

            % Get the list of items
            list = this.ContentsList;

            % Get the selected items
            list = list(this.PanelContentIndices);

            itemLabelList = cell(0);
            itemValueList = cell(0);
            cnt = 1;
            for p=1:length(list)
                itemLabel = list(p).ScreenName;
                itemUnit = list(p).Unit;

                % Get the item value
                itemValue = getItemValue(this, hEye, list(p));
                [numRows, numCols] = size(itemValue);

                if (numCols == 1)
                    % Get the enigneering formatted value
                    [formattedValue engUnit] = formatItemValue(this, itemValue(:,1), 3, ...
                        itemUnit);
                    [itemValueList{1:numRows, cnt}] = formattedValue{:};

                    % Add the engineering unit and unit to the label
                    if isempty(itemUnit)
                        itemLabelList{cnt} = sprintf('%s:', itemLabel);
                    else
                        itemLabelList{cnt} = ...
                            sprintf('%s (%s%s):', itemLabel, engUnit, itemUnit);
                    end
                    cnt = cnt+1;
                else
                    for n=1:numCols
                        % Get the enigneering formatted value
                        [formattedValue engUnit] = formatItemValue(this, itemValue(:,n), ...
                            3, itemUnit);
                        [itemValueList{1:numRows, cnt}] = formattedValue{:};

                        % Add the engineering unit and unit to the label
                        if isempty(itemUnit)
                            itemLabelList{cnt} = sprintf('%s [%d]:', itemLabel, n);
                        else
                            itemLabelList{cnt} = ...
                                sprintf('%s [%d] (%s%s):', itemLabel, n, engUnit, itemUnit);
                        end
                        cnt = cnt+1;
                    end
                end
            end

            tableData = [itemLabelList; itemValueList]';

            if size(tableData, 2) == 3
                columnLabels = {'Type', ...
                    {'Value(I)', 'In-phase value'}, ...
                    {'Value(Q)', 'Quadrature Value'}};
            else
                columnLabels = {'Type', 'Value'};
            end
        end
        %-----------------------------------------------------------------------
        function me = prepareCompareTableData(this, eyeStr)
            %PREPARETABLEDATA Prepare eye measurements comparison table data
            %   PREPARECOMPARETABLEDATA(THIS, EYESTR) prepares a cell matrix
            %   that contains all the information about the eye diagrams in the 
            %   EYESTR.  EYESTR is a vector of eye diagram structures.

            % Get the number of eye diagram structures and data structure
            numEyeObjs = length(eyeStr);
            data = this.CompareTableData;
            measNames = fieldnames(data.Measurements);

            % Get the list of measurements
            list = this.ContentsList;
            numMeasurements = length(list);

            % Reset the fields
            for p=1:length(measNames)
                data.Measurements.(measNames{p}).InPhase = [];
                data.Measurements.(measNames{p}).Quadrature = [];
            end
            data.EyeObjNames = [];
            me = [];

            if numEyeObjs
                % Loop over all the eye diagram objects in the memory.  Collect
                % all the item values needed, so that we can select a common
                % engineering unit.  Also, populate the eye diagram object name
                % field of the table.
                for p=1:numEyeObjs

                    hEye = eyeStr(p).Handle;
                    data.EyeObjNames{p, 1} = [eyeStr(p).Source '_' eyeStr(p).Name];

                    if strncmp(hEye.OperationMode, 'Real', 4)
                        quadrature = false;
                    else
                        quadrature = true;
                    end
                    
                    me = updateAnalysisResults(hEye);

                    for q=1:numMeasurements
                        % Get the item value
                        itemValue = getItemValue(this, hEye, list(q));
                        temp.(measNames{q}).InPhase(p,:) = itemValue(1,:);
                        if quadrature
                            temp.(measNames{q}).Quadrature(p,:) = itemValue(2,:);
                        else
                            temp.(measNames{q}).Quadrature(p,:) = NaN(size(itemValue));
                        end
                    end
                end

                for p=1:numMeasurements
                    itemUnit = list(p).Unit;

                    % Get the enigneering formatted value
                    [formattedValue engUnit] = formatItemValue(this, ...
                        temp.(measNames{p}).InPhase, 3, itemUnit, 'f');
                    data.Measurements.(measNames{p}).InPhase = ...
                        num2cell(formattedValue);
                    if ~isempty(itemUnit)
                        data.Measurements.(measNames{p}).InPhaseUnit = ...
                            sprintf('(%s%s)', engUnit, itemUnit);
                        if strcmp(itemUnit, 's')
                            data.YLabel{p+1}.InPhase = ...
                                sprintf('Time (%ss)', engUnit);
                        else
                            data.YLabel{p+1}.InPhase = ...
                                sprintf('Amplitude (%sAU)', engUnit);
                        end
                    else
                        data.Measurements.(measNames{p}).InPhaseUnit = '';
                        data.YLabel{p+1}.InPhase = 'Unitless';
                    end
                    
                    [formattedValue engUnit] = formatItemValue(this, ...
                        temp.(measNames{p}).Quadrature, 3, itemUnit, 'f');
                    data.Measurements.(measNames{p}).Quadrature = ...
                        num2cell(formattedValue);
                    if ~isempty(itemUnit)
                        data.Measurements.(measNames{p}).QuadratureUnit = ...
                            sprintf('(%s%s)', engUnit, itemUnit);
                        if strcmp(itemUnit, 's')
                            data.YLabel{p+1}.Quadrature = ...
                                sprintf('Time (%ss)', engUnit);
                        else
                            data.YLabel{p+1}.Quadrature = ...
                                sprintf('Amplitude (%sAU)', engUnit);
                        end
                    else
                        data.Measurements.(measNames{p}).QuadratureUnit = '';
                        data.YLabel{p+1}.Quadrature = 'Unitless';
                    end
                end
            end % if ~numEyeObjs
            this.CompareTableData = data;
            
        end % prepareCompareTableData
        %-----------------------------------------------------------------------
        function [tableData columnLabels yLabel] = ...
                formatCompareTableData(this, quadrature)
            %formatCompareTableData Prepare table data for uitable
            %   This function formats the data in the CompareTableData based on
            %   the ContentsList that can be used as an input to the uitable.
            %   measType output is the measurements type, which is used to
            %   identify the Y-axis the line is going to the plotted.

            % Get the number of eye diagram structures
            data = this.CompareTableData;
            numRows = size(data.EyeObjNames, 1);
            tableData = {};
            columnLabels = {};
            yLabel = {};

            if ~isempty(data.EyeObjNames)
                % Get the field names for the measurements structure
                measNames = fieldnames(data.Measurements);

                % Get the sorted list of items.  Filter with the selected
                % (checked) indices.
                listIdx = this.PanelContentIndices;
                listIdx = listIdx(this.SelectedIndices(this.PanelContentIndices));

                % Scan the data and decide on the number of columns needed
                numCol = 1;  % One for the eye diagram object name
                for p=listIdx
                    numCol = numCol + ...
                        size(data.Measurements.(measNames{p}).InPhase, 2);
                end
                if quadrature
                    % We quadrature components are needed, then add those to the
                    % numCol.  Note that one of the columns is for eye diagram
                    % object name.
                    numCol = 2*(numCol-1)+1;
                end

                % Initialize table data
                columnLabels = cell(numCol,1);
                columnLabels{1} = data.ColumnNames{1};
                tableData = cell(numRows, numCol);
                [tableData{:, 1}] = data.EyeObjNames{:};
                yLabel = cell(numCol,1);

                colCnt = 1;
                for p = 1:length(listIdx)
                    idx = listIdx(p);
                    if quadrature
                        [tableData, columnLabels, yLabel, colCnt] = ...
                            add2TableData(tableData, columnLabels, yLabel, ...
                            colCnt, data, idx, measNames{idx}, 'I', true);
                        [tableData, columnLabels, yLabel, colCnt] = ...
                            add2TableData(tableData, columnLabels, yLabel, ...
                            colCnt, data, idx, measNames{idx}, 'Q', true);
                    else
                        [tableData, columnLabels, yLabel, colCnt] = ...
                            add2TableData(tableData, columnLabels, yLabel, ...
                            colCnt, data, idx, measNames{idx}, 'I', false);
                    end
                end

            end % if ~numEyeObjs
        end % formatCompareTableData
    end

    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function createList(this)
            %CREATESETTINGSLIST Create a list of eye diagram object settings
            %   SETTINGSLIST = CREATESETTINGSLIST(THIS) creates a vector of
            %   structure with field names:
            %       'FieldName'  - name of the eye diagram object property
            %       'ScreenName' - label that is displayed on the GUI for that
            %                      property
            %       'Unit'       - unit of the property
            %       'QuickHelp'  - quick help string
            %   Each element of the vector represents an eye diagram object
            %   setting that is displayed in the GUI.

            fieldNames = {'FieldName', 'ScreenName', 'Unit'};
            measurementsListCell = {...
                'Measurements.EyeCrossingTime', 'Crossing Time', 's';...
                'Measurements.EyeCrossingAmplitude', 'Crossing Amplitude', 'AU';...
                'Measurements.EyeCrossingPercentage', 'Crossing Amplitude (%)', '';
                'Measurements.EyeDelay', 'Eye Delay', 's';...
                'Measurements.EyeLevel', 'Eye Level', 'AU';...
                'Measurements.EyeAmplitude', 'Eye Amplitude', 'AU';...
                'Measurements.EyeHeight', 'Eye Height', 'AU';...
                'Measurements.EyeOpeningVertical', 'Vertical Opening', 'AU';...
                'Measurements.EyeSNR', 'Eye SNR', '';...
                'Measurements.QualityFactor', 'Quality Factor', '';...
                'Measurements.EyeWidth', 'Eye Width', 's';...
                'Measurements.EyeOpeningHorizontal', 'Horizontal Opening', 's';...
                'Measurements.JitterRandom', 'Random Jitter', 's';...
                'Measurements.JitterDeterministic', 'Deterministic Jitter', 's';...
                'Measurements.JitterTotal', 'Total Jitter', 's';...
                'Measurements.JitterRMS', 'RMS Jitter', 's';...
                'Measurements.JitterPeakToPeak', 'Peak to Peak Jitter', 's';...
                'Measurements.EyeRiseTime', 'Rise Time', 's';...
                'Measurements.EyeFallTime', 'Fall Time', 's'};
            measurementsList = cell2struct(measurementsListCell, fieldNames, 2);

            measurementsQuickHelp = {...
                ['The mean value of time at which the eye diagram crosses ' ...
                'the amplitude level defined by reference amplitude values.'];...
                'The mean amplitude value of the eye diagram at the eye crossing time.';...
                'The eye crossing amplitude value as a percentage of the eye amplitude.';
                ['The distance of the mid-point of the eye to the time origin, which '...
                'is the leftmost of the time axis.'];...
                ['The mean value of distinct eye levels around the eye delay value.  '...
                'The eye levels are calculated within the eye level boundaries.']; ...
                'The distance between neighboring eye level values.';...
                ['The vertical distance between two point that are three '...
                'standard deviations from the mean eye level towards the center '...
                'of the eye.'];...
                ['Vertical eye opening value measured at a BER value defined by the '...
                'BER threshold value.'];...
                'Signal-to-noise ratio of the eye diagram.';...
                'Quality factor of the eye.';...
                ['The horizontal distance between two points that are three standard '...
                'deviations from eye crossing times towards the center of '...
                'the eye.'];...
                ['Horizontal eye opening value measured at a BER value defined by the '...
                'BER threshold value.'];...
                ['Random jitter measured at the reference amplitude at the BER '...
                'value defined by BER threshold.'];...
                'Deterministic jitter at reference amplitude.';...
                'Sum of random and deterministic jitter values.';...
                'RMS value of the jitter measured at reference amplitude.';...
                'Peak-to-peak value of the jitter measured at reference amplitude.';...
                ['Rise time of the eye measured at two edge values defined by the '...
                'amplitude thresholds.'];...
                ['Fall time of the eye measured at two edge values defined by the '...
                'amplitude thresholds.'];...
                };

            [measurementsList.QuickHelp] = deal(measurementsQuickHelp{:});

            this.ContentsList = measurementsList;

            this.PanelContentIndices = this.DefaultPanelContentIndices;

            % Create a structure with field names same as the field names of the
            % measurements object.  Also add a field to store eye diagram object
            % names and column names.
            fieldNames = strrep(getFieldNames(this), 'Measurements.', '');
            this.CompareTableData.Measurements = ...
                cell2struct(cell(length(fieldNames),1),fieldNames);
            this.CompareTableData.EyeObjNames = {};
            this.CompareTableData.ColumnNames = ...
                ['Eye Object' getScreenNames(this)]';
        end
    end
    
    %===========================================================================
    % Private methods
    methods (Access = private)
        function selectedIndices = getDefaultSelectedIndices(this)
            % Select the first three
            selectedIndices = false(length(this.ContentsList),1);
            selectedIndices(this.PanelContentIndices(1:3)) = true;
        end
    end
end

%===============================================================================
% Helper functions
function [tableData, columnLabels, yLabel, colCnt] = ...
    add2TableData(tableData, columnLabels, yLabel, colCnt, data, idx, ...
    measName, IorQ, suffixFlag)

if IorQ == 'I'
    meas = data.Measurements.(measName).InPhase;
    unit = data.Measurements.(measName).InPhaseUnit;
    ylab = data.YLabel{idx+1}.InPhase;
    if suffixFlag
        suffix = ' (I)';
    else
        suffix = '';
    end
else
    meas = data.Measurements.(measName).Quadrature;
    unit = data.Measurements.(measName).QuadratureUnit;
    ylab = data.YLabel{idx+1}.Quadrature;
    if suffixFlag
        suffix = ' (Q)';
    else
        suffix = '';
    end
end

if ~isempty(unit)
    unit = [' ' unit];
end
    
tempNumCol = size(meas, 2);
for q=1:tempNumCol
    if tempNumCol == 1
        columnLabels{colCnt+q} = ...
            sprintf('%s%s%s', data.ColumnNames{idx+1}, suffix, unit);
    else
        columnLabels{colCnt+q} = ...
            sprintf('%s [%d]%s%s', ...
                data.ColumnNames{idx+1}, q, suffix, unit);
    end
    [tableData{:, colCnt+q}] = deal(meas{:,q});
    yLabel{colCnt+q} = ylab;
end
colCnt = colCnt + tempNumCol;
end

%-------------------------------------------------------------------------------
function me = updateAnalysisResults(hEye)
me = [];
try
    % Save the warning state and turn off warning
    warnState = warning('query', 'all');
    warning('off', ...
        'comm:commscope:eyemeasurements:NotEnoughData');
    warning('off', ...
        'comm:commscope:eyediagram:OutOfRange');
    analyze(hEye);
catch me
    % Delay the error until we are done with the table data
end
% Restore the warning state
warning(warnState);
end
%-------------------------------------------------------------------------------
%[EOF]

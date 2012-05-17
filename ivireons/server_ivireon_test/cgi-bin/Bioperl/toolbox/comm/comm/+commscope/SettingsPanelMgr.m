classdef SettingsPanelMgr < commscope.InfoPanelMgr
    %SettingsPanelMgr Construct a settings panel manager for EyeScope
    %
    %   Warning: This undocumented function may be removed in a future release.

    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $  $Date: 2008/09/13 06:46:03 $

    %===========================================================================
    % Public methods
    methods
        function this = SettingsPanelMgr
            % Set the default panel content indeices and create list
            this.DefaultPanelContentIndices = [1 3 10 13 14];
            createList(this);
        end
        %-----------------------------------------------------------------------
        function [tableData columnLabels msg] = prepareTableData(this, eyeStr)
            %PREPARETABLEDATA Prepare eye object settings table data
            %   [TABLEDATA COLUMNLABELS] = PREPARETABLEDATA(THIS)
            %   prepares a cell matrix table to use as an input to the table
            %   object for the eye diagram object settings panel.

            % Get the list of items
            list = this.ContentsList;

            % Check that all the settings are the same for all the eye diagram
            % objects
            [disparateValues msg] = checkValueDisparity(this, eyeStr, list);

            % Get the selected items
            list = list(this.PanelContentIndices);

            % Format the table data based on selected list items
            if isempty(eyeStr)
                hEye = [];
            else
                hEye = eyeStr(1).Handle;
            end
            itemLabelList = cell(0);
            itemValueList = cell(0);
            cnt = 1;
            for p=1:length(list)
                itemLabel = list(p).ScreenName;
                itemUnit = list(p).Unit;

                % Get the item value.  If this is a disparate value, then use
                % dash '-'.
                if ~any(strmatch(list(p).ScreenName, disparateValues))
                    itemValue = getItemValue(this, hEye, list(p));
                else
                    itemValue = '-';
                end
                [m, n] = size(itemValue); %#ok

                if any(strmatch(itemLabel, {'Crossing Band Width'}, 'exact')) ...
                        && ~strcmp(itemValue, '-')
                    % Convert to percentage
                    itemValue = 100*itemValue;
                end

                [formattedValue engUnit] = formatItemValue(this, itemValue, 3, itemUnit);

                % Store the values
                [itemValueList{cnt:cnt+m-1}] = formattedValue{:};

                if m > 1
                    % If both I and Q

                    % Store the engineering unit with the unit and label
                    if isempty(itemUnit)
                        itemLabelList{cnt} = sprintf('%s [I]:', itemLabel);
                        itemLabelList{cnt+1} = sprintf('%s [Q]:', itemLabel);
                    else
                        itemLabelList{cnt} = ...
                            sprintf('%s [I] (%s%s):', itemLabel, engUnit, itemUnit);
                        itemLabelList{cnt+1} = ...
                            sprintf('%s [Q] (%s%s):', itemLabel, engUnit, itemUnit);
                    end
                    cnt = cnt+2;
                else
                    % If only I measurements

                    % Store the engineering unit with the unit and label
                    if isempty(itemUnit)
                        itemLabelList{cnt} = sprintf('%s:', itemLabel);
                    else
                        itemLabelList{cnt} = sprintf('%s (%s%s):', itemLabel, engUnit, itemUnit);
                    end
                    cnt = cnt+1;
                end
            end

            tableData = [itemLabelList; itemValueList]';

            columnLabels = {'Setting', 'Value'};
        end
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
            settingsListCell = {...
                'SamplingFrequency', 'Sampling Frequency', 'Hz';...
                'SamplesPerSymbol', 'Samples per Symbol', '';...
                'SymbolRate', 'Symbol Rate', 'Sps'; ...
                'SymbolsPerTrace', 'Symbols per Trace', ''; ...
                'MinimumAmplitude', 'Minimum Amplitude', 'AU'; ...
                'MaximumAmplitude', 'Maximum Amplitude', 'AU';...
                'AmplitudeResolution', 'Amplitude Resolution', 'AU'; ...
                'MeasurementDelay', 'Measurement Delay', 's'; ...
                'SamplesProcessed', 'Samples Processed', '';...
                'MeasurementSetup.EyeLevelBoundary', 'Eye Level Boundaries', '%'; ...
                'MeasurementSetup.ReferenceAmplitude', 'Reference Amplitude', 'AU'; ...
                'MeasurementSetup.CrossingBandWidth', 'Crossing Band Width', '%'; ...
                'MeasurementSetup.BERThreshold', 'BER Threshold', ''; ...
                'MeasurementSetup.AmplitudeThreshold', 'Amplitude Threshold', '%'; ...
                'MeasurementSetup.JitterHysteresis', 'Jitter Hysteresis', 'AU'};
            settingsList = cell2struct(settingsListCell, fieldNames, 2);

            settingsQuickHelp = {'Sampling frequency of the raw data.';...
                'Number of samples used to represent a symbol.';...
                'Symbol rate of the tested system in symbols per second.';...
                'Number of symbols in one trace of the eye diagram.';...
                'Minimum amplitude value that can be processed by the eye diagram.';...
                'Maximum amplitude value that can be processed by the eye diagram.';...
                'The resolution of the amplitude axis.';...
                'The time duration the scope waits before starting to collect data.';...
                'Number of processed samples of raw data.';...
                ['The left and right boundaries of the band used for eye level '...
                'measurements.'];...
                ['The amplitude value used to calculate the crossing times and jitter '...
                'of the eye diagram.'];...
                ['Upper and lower boundaries of the band used to calculate crossing time '...
                'values.'];...
                ['Bit error rate threshold used to calculate random jitter and eye '...
                'opening values.'];...
                ['Upper and lower edge values used to calculate rise and fall time '...
                'values.'];...
                ['Hysteresis value used to decide if the input signal crossed a '...
                'reference amplitude level.']};

            [settingsList.QuickHelp] = deal(settingsQuickHelp{:});

            this.ContentsList = settingsList;

            this.PanelContentIndices = this.DefaultPanelContentIndices;

        end
        %-----------------------------------------------------------------------
        function [disparateValues msg] = checkValueDisparity(this, hEye, list)
            % Check that the values in all the eye diagrams in the eye diagram objects are
            % the same across all the objects in the hEye vector.  disparateValues lists
            % the index of the eye diagram object in the list and the disparate value in a
            % cell array.  Note that the reference is the first eye diagram in the list.

            disparateValues = {};
            msg = '';
            idxMsg = '';
            flag = 0;
            singularSetting = 1;

            if ~isempty(hEye)
                disparateIdx = [];
                valuesMsg = '';
                hRef = hEye(1).Handle;
                for p=1:length(hEye)
                    h = hEye(p).Handle;
                    for q=1:length(list)
                        itemValueP = getItemValue(this, h, list(q));
                        itemValue1 = getItemValue(this, hRef, list(q));
                        if itemValueP ~= itemValue1
                            disparateValues = [disparateValues; list(q).ScreenName]; %#ok<AGROW>
                            if isempty(valuesMsg)
                                valuesMsg = sprintf('   %s',list(q).ScreenName);
                            else
                                valuesMsg = sprintf('%s\n   %s', valuesMsg, list(q).ScreenName);
                                singularSetting = 0;  % more than one setting is conflicting
                            end
                            flag = 1;
                            disparateIdx = [disparateIdx; p]; %#ok<AGROW>
                        end
                    end
                    if flag
                        if isempty(idxMsg)
                            idxMsg = sprintf('%d', p);
                        else
                            idxMsg = sprintf('%s, %d', idxMsg, p);
                        end
                        flag = 0;
                    end
                end

                if ~isempty(idxMsg)
                    msg = sprintf(['One or more measurement settings of the eye diagram object %s are '...
                        'different from the other eye diagram objects in the table.%s'], idxMsg);
                    if singularSetting
                        msg = sprintf('%s Conflicting setting is:\n%s', msg, valuesMsg);
                    else
                        msg = sprintf('%s Conflicting settings are:\n%s', msg, valuesMsg);
                    end
                end
            end
        end
    end
end
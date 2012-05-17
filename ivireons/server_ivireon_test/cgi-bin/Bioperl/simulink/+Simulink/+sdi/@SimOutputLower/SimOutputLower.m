classdef SimOutputLower

    % Copyright 2010 The MathWorks, Inc.

    methods (Static = true)

        % Returns timeseries lowered into scalar samples.  Note,
        % because of the magnitude of data returned there are
        % special considerations:
        %
        % 1. Only one simulation output can be passed in at a 
        %    time.  It is recommended that the caller similarly
        %    limits the number of lowered outputs.
        %
        % 2. Objects are not returned as the number would be large
        %    and cycle detection would impede performance.
        function result = lower(soeOutput)
            % Assume nothing lowered
            result = [];

            % If data at each sample is scalar
            if isScalarTimeseriesOutput(soeOutput)
                result = lowerScalarTimeseries(soeOutput, 1);

            % If the data at each sample is a vector
            elseif isVectorTimeseriesOutput(soeOutput)
                result = lowerVectorTimeseries(soeOutput);

            % If the data at each sample is a 2D matrix
            elseif is2DTimeseriesOutput(soeOutput)
                result = lower2DTimeseries(soeOutput);
            end
        end

    end % methods

end % classdef

function result = isScalarTimeseriesOutput(soeOutput)
    result = soeOutput.SampleDims == 1;
end

function result = isVectorTimeseriesOutput(soeOutput)
    result = isscalar(soeOutput.SampleDims);
end

function result = is2DTimeseriesOutput(soeOutput)
    result = ndims(soeOutput.SampleDims) == 2;
end

function result = lowerScalarTimeseries(soeOutput, channel)

    % Simple repackage from object to structure
    result.RootSource  = soeOutput.RootSource; 
    result.TimeSource  = soeOutput.TimeSource;
    result.DataSource  = soeOutput.DataSource;
    if isempty(soeOutput.rootDataSrc)
        result.rootDataSrc = soeOutput.DataSource;
    else
        result.rootDataSrc = soeOutput.rootDataSrc;
    end
    result.DataValues  = soeOutput.DataValues;
    result.TimeValues  = soeOutput.TimeValues;
    result.BlockSource = soeOutput.BlockSource;
    result.ModelSource = soeOutput.ModelSource;
    result.SignalLabel = soeOutput.SignalLabel;
    result.TimeDim     = soeOutput.TimeDim;
    result.SampleDims  = soeOutput.SampleDims;
    result.PortIndex   = soeOutput.PortIndex;
    result.Channel     = channel;
    result.SID         = soeOutput.SID;
    result.DataValues  = timeseries(result.DataValues, result.TimeValues);
end

function result = lowerVectorTimeseries(soeOutput)

    % Assume nothing lowered
    result = [];

    % Cache original source and values
    originalDataSource = soeOutput.DataSource;
    originalDataValues = soeOutput.DataValues;

    % Get length of vector
    vectorExtent = soeOutput.SampleDims;

    for i = 1 : vectorExtent
        % Get channel
        if soeOutput.TimeDim == 1
            channelStr  = '%s(:,%d)';
            channelVals = originalDataValues(:, i);
        else
            channelStr  = '%s(%d,:)';
            channelVals = originalDataValues(i, :);
        end

        % Cache channel
        soeOutput.DataSource = sprintf(channelStr, originalDataSource, i);
        soeOutput.rootDataSrc = originalDataSource;
        soeOutput.DataValues = channelVals;

        % Add this channel
        temp = lowerScalarTimeseries(soeOutput, i);
        result = [result temp];
    end % for i
end

function result = lower2DTimeseries(soeOutput)

    % Cache original source and values
    originalDataSource = soeOutput.DataSource;
    originalDataValues = soeOutput.DataValues;

    % Calculate the data extents
    rowExtent = soeOutput.SampleDims(1);
    colExtent = soeOutput.SampleDims(2);

    for r = 1 : rowExtent
        for c = 1 : colExtent
            % Get channel
            if soeOutput.TimeDim == 1
                channelStr  = '%s(:,%d,%d)';
                channelVals = originalDataValues(:, r, c);
                channelVals = squeeze(channelVals);
            else
                channelStr  = '%s(%d,%d,:)';
                channelVals = originalDataValues(r, c, :);
                channelVals = squeeze(channelVals);
            end

            % Cache channel
            soeOutput.DataSource = sprintf(channelStr,         ...
                                           originalDataSource, ...
                                           r, c);
            soeOutput.DataValues = channelVals;
            soeOutput.rootDataSrc = originalDataSource;
            
            % Add this channel
            result(r, c) = lowerScalarTimeseries(soeOutput, [r, c]);
        end % c
    end % r
end
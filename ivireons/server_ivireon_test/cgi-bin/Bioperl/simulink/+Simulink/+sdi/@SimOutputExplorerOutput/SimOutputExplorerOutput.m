classdef SimOutputExplorerOutput < handle

    % Copyright 2009-2010 The MathWorks, Inc.

    properties (Access = 'public')
        RootSource;  % Root object name where time series found
        TimeSource;  % Time field name inside RootSource
        DataSource;  % Data field name inside RootSource
        TimeValues;  % Value of time vector inside RootSource
        DataValues;  % Value of data vector inside RootSource
        BlockSource; % Signal source name of time series
        ModelSource; % Parent model name of BlockSource
        SignalLabel; % Label of signal
        TimeDim;     % Which dimension is time
        SampleDims;  % Dimensions of signal at sample
        PortIndex;   % Port index
        SID;         % Stable identifier
        rootDataSrc; % original data source
    end

    methods (Access = 'public')

        function this = SimOutputExplorerOutput()
            this.RootSource  = [];
            this.TimeSource  = [];
            this.DataSource  = [];
            this.DataValues  = [];
            this.BlockSource = [];
            this.ModelSource = [];
            this.SignalLabel = [];
            this.TimeDim     = [];
            this.SampleDims  = [];
            this.PortIndex   = [];
            this.SID         = [];
            this.rootDataSrc = '';
        end

    end % public methods

end % classdef

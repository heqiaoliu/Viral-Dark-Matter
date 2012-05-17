function [tolStruct, syncStruct] = defaultTolAndSyncOptions()

    % Default options for aligning and comparing timeseries
    %
    % Copyright 2010 The MathWorks, Inc.

    tolStruct.toleranceType        = 0;
    tolStruct.absolute             = 0;
    tolStruct.relative             = 0;
    tolStruct.timeStart            = 0;
    tolStruct.timeEnd              = 0;
    tolStruct.timeStep             = 0;
    tolStruct.initAbsTolVal        = 0;
    tolStruct.absStep              = 0;
    tolStruct.initRelTolVal        = 0;
    tolStruct.relStep              = 0;
    tolStruct.fcnCall              = '' ;
    syncStruct.SyncMethod          = 'union';
    syncStruct.InterpMethod        = 'zoh';
    syncStruct.UniformTimeInterval = 0.0100;
    syncStruct.customSyncMethod    = '';
    syncStruct.syncType            = 0;
end
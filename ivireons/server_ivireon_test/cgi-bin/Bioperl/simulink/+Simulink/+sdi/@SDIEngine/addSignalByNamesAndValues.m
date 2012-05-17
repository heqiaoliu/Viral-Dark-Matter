function signalID = addSignalByNamesAndValues(this, varargin)
    
    % Copyright 2010 The MathWorks, Inc.
    
    % This function provides the functionality to add data to a run by name
    % value property pairs.
    % An example use will be as follows (as used by FPT):
    % sdiEngine = getSDIEngine(h);
    % runID = getRunID(h, runNumber);
    % signalID = sdiEngine.addSignalByNamesAndValues('runID',runID,'metaData',result);
    %
    % Possible property names are: 'runID', 'rootSource', 'timeSource', 
    % 'dataSource', 'dataValues', 'blockSource', 'modelSource',
    % 'signalLabel', 'timeDimension', 'sampleDimension', 'portIndex',
    % 'channel', 'SID', 'metaData', 'parentID', 'rootDataSrc'

    % create input parser
    p = inputParser;
   
    % add parameter values, default values and validators
    p.addParamValue('runID', @isinteger);
    p.addParamValue('rootSource', '', @ischar);
    p.addParamValue('timeSource', '', @ischar);
    p.addParamValue('dataSource', '', @ischar);
    p.addParamValue('dataValues', [], @(x)(isempty(x) || isa(x, 'timeseries')));
    p.addParamValue('blockSource', '', @ischar);
    p.addParamValue('modelSource', '', @ischar);
    p.addParamValue('signalLabel', '', @ischar);
    p.addParamValue('timeDimension', [], @(x)(isempty(x) || isinteger(x)));
    p.addParamValue('sampleDimension', [], @(x)(isempty(x) || isinteger(x)));
    p.addParamValue('portIndex', [], @(x)(isempty(x) || isinteger(x)));
    p.addParamValue('channel', [], @(x)(isempty(x) || isinteger(x)));
    p.addParamValue('SID', '', @ischar);
    p.addParamValue('metaData', []);
    p.addParamValue('parentID', []);
    p.addParamValue('rootDataSrc','', @ischar);
    
    p.parse(varargin{:});
    results = p.Results;   
   
    % prepare the data to be populated in Signal repository
    runID = results.runID;
    rootSource = results.rootSource;
    timeSource = results.timeSource;
    dataSource = results.dataSource;
    dataValues = results.dataValues;
    blockSource = results.blockSource;
    modelSource = results.modelSource;
    signalLabel = results.signalLabel;
    timeDimension = results.timeDimension;
    sampleDimension = results.sampleDimension;
    portIndex = results.portIndex;
    channel = results.channel;
    SID = results.SID;
    metaData = results.metaData;
    parentID = results.parentID;
    rootDataSrc = results.rootDataSrc;
    
    % add the data to signal repository
    signalID = this.sigRepository.add(this, runID, rootSource, timeSource, ...
                                      dataSource, dataValues, blockSource, ...
                                      modelSource, signalLabel,            ...
                                      timeDimension, sampleDimension,      ...
                                      portIndex, channel, SID, metaData,   ...
                                      parentID, rootDataSrc);
end


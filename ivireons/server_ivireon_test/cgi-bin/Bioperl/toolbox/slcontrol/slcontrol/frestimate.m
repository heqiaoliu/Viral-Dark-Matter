function varargout = frestimate(model,varargin)
% FRESTIMATE Estimates the frequency response of Simulink model.
%
%   SYSEST = FRESTIMATE('mdl',IO,IN) takes a Simulink model name, 'mdl' and
%   an I/O object, IO, and an input signal IN as inputs and returns an frd
%   object SYSEST. The linearization I/O object is created with the
%   function GETLINIO or LINIO. IO must be associated with the same
%   Simulink model,mdl. IN should be either one of the offered frequency
%   response estimation signals (sinestream, chirp or random) or a MATLAB
%   timeseries object.
%
%   SYSEST = FRESTIMATE('mdl',OP,IO,IN) takes a Simulink model name, 'mdl',
%   an operating point object, OP, an I/O object IO, and an input signal IN
%   as inputs and returns an frd object, SYSEST. The operating point object
%   is created with the function OPERPOINT or FINDOP. The linearization I/O
%   object is created with the function GETLINIO or LINIO. Both OP and IO
%   must be associated with the same Simulink model, mdl. IN should be
%   either one of the offered frequency response estimation signals
%   (sinestream, chirp or random) or a MATLAB timeseries object. 
%
%   [SYSEST,SIMOUT] = FRESTIMATE('mdl',OP,IO,IN) takes a Simulink model
%   name, 'mdl', an operating point object, OP, an I/O object IO, and an
%   input signal IN as inputs and returns an frd object, SYSEST and the
%   simulation output SIMOUT, a cell array of Simulink.Timeseries
%   objects with dimensions m by n where m is the number of output
%   linearization IOs and n is the total number of input channels 
%   specified in IO. The operating point object is created with the
%   function OPERPOINT or FINDOP. The linearization I/O object is created
%   with the function GETLINIO or LINIO. Both OP and IO must be associated
%   with the same Simulink model, mdl. IN should be either one of the
%   offered frequency response estimation signals (sinestream, chirp or
%   random) or a MATLAB timeseries object.
%
%   [SYSEST,SIMOUT] = FRESTIMATE('mdl',OP,IO,IN,OPTIONS) estimates the
%   frequency response of the Simulink model 'mdl' using the options object
%   OPTIONS. The frequency response estimation options object is created
%   with the function FRESTIMATEOPTIONS and contains options for frequency
%   response estimation.
%
%   See also frest.Sinestream frestimateOptions

%  Author(s): Erman Korkut 22-Feb-2009
%  Revised:
%  Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.10.15 $ $Date: 2010/05/20 03:25:50 $

% Check number of input & output arguments
numout = nargout;
error(nargchk(3,5,nargin));
error(nargoutchk(0,2,numout));

% Check that the built-in s-function names are not shadowed.
if numel(which('scd_gatherinfo','-all')) > 1
    ctrlMsgUtils.error('Slcontrol:frest:NameClashSFunc','scd_gatherinfo')     
elseif numel(which('scd_injection_main','-all')) > 1
    ctrlMsgUtils.error('Slcontrol:frest:NameClashSFunc','scd_injection_main')
elseif numel(which('scd_injection_input','-all')) > 1
    ctrlMsgUtils.error('Slcontrol:frest:NameClashSFunc','scd_injection_input')
end

% Parse input arguments
op=[]; io=[]; in=[]; opts=frestimateOptions;
for ct = 1:nargin-1
    var = varargin{ct};
    if isa(var,'linearize.IOPoint')
        io  = var;
        ActiveInd = strcmp(get(io,{'Active'}),'on');
        io = io(ActiveInd);
        % Test to be sure that the IOs have unique block/port
        % combinations     
        if ~isIOsUnique(io)
            ctrlMsgUtils.error('Slcontrol:frest:UniqueIOBlockPortPairNeeded')
        end
    elseif isa(var, 'opcond.OperatingPoint')
        op = var;        
    elseif LocalIsInputSignal(var)
        in = var;
    elseif isa(var,'frest.Frestoptions')
        opts = var;
    end  
end

% Check to see if the required input arguments, input and IO, exist
if (~isa(in,'timeseries') && isempty(in)) || isempty(io)
    ctrlMsgUtils.error('Slcontrol:frest:InsufficientInputArguments')
end

% Check to see if the operating point matches the model if there is one
if ~isempty(op) && ~(strcmp(model,op.Model))
    ctrlMsgUtils.error('Slcontrol:frest:ModelDoesNotMatchOperatingPoint')        
end

% Setup for simulation
[parammgr,SimulationPackage] = LocalSetupForSimulation(model,io,op,in,numout,opts);
numExperiments = SimulationPackage.NumberOfExperiments;

% Check to see if we should use parfor and run the setup if we should
useParFor = strcmp(opts.UseParallel,'on');
if useParFor
    if ~isempty(ver('distcomp'))
        % Determine what to distribute
        if SimulationPackage.IsOneAtATimeSinestream
            distributeOverFreq = true;
        else
            distributeOverFreq = false;
        end
        % If there is only a single channel and not OneAtATime Sinestream,
        % throw a warning
        if ~distributeOverFreq && numExperiments == 1
            ctrlMsgUtils.warning('Slcontrol:frest:ParallelSpecifiedButWontBeUsed');
            useParFor = false;
        else
            simModeOnClient = get_param(parammgr.Model,'SimulationMode');
            % Restore model for a clean start with parfor
            LocalRestoreModel(parammgr,SimulationPackage)
            nWorkers = matlabpool('size');
            if nWorkers == 0
                ctrlMsgUtils.error('Slcontrol:frest:ParallelPoolClosed');
            end
            str = parallelsim.getDirtyLoadedModels(model);
            if ~isempty(str)
                ctrlMsgUtils.error('Slcontrol:frest:ParallelDirtyModel',str);
            end
            % Setup workers
            parallelsim.setupWorkers(model,opts.ParallelPathDependencies);
            % Wrap objects in MCOS for parfor
            ioObj = parallelsim.uddWrapper;ioObj.uddObj = io;
            opObj = parallelsim.uddWrapper;opObj.uddObj = op;
            % Create individual copies of ModelParameterMgr and
            % SimulationPackage at each worker
            workerVarNames = cell(1,nWorkers);
            simModeOnWorkers = cell(1,nWorkers);
            parfor ctw = 1:nWorkers
                [parammgrw,simpackagew] = LocalSetupForSimulation(model,ioObj,opObj,in,numout,opts);
                workerVarNames{ctw} = LocalWriteSimulationMaterialInWorker(parammgrw,simpackagew,[]);
                simModeOnWorkers{ctw} = get_param(parammgrw.Model,'SimulationMode');
            end
            % Error if normal/rapid is not consistent between client and
            % workers
            if ~all(strcmp(simModeOnClient,simModeOnWorkers))
                % Clean up before erroring out
                LocalRestoreWorkers(model,workerVarNames,nWorkers);
                % Error
                ctrlMsgUtils.error('Slcontrol:frest:RapidAccelInconsistency',parammgr.Model);
            end
            useParFor = true;
        end
    else
        % PCT not installed
        ctrlMsgUtils.warning('Slcontrol:frest:ParallelSpecifiedWithoutPCT');
        useParFor = false;
    end
else
    useParFor = false;
end

% Simulation loop
simout = cell(1,numExperiments);
if ~useParFor
    for ctexp = 1:numExperiments
        % If this is a sinestream that needs to be simulated OneAtATime, there
        % will be another simulation loop.
        if SimulationPackage.IsOneAtATimeSinestream
            % Get injection data for current experiment
            injdata = SimulationPackage.InjectionDataArray(ctexp).InjectionData;            
            % If it is of constant sample time over frequencies and rapid
            % acceleator, build it and do not check again till next time.
            try
                rtp = LocalBuildForRapidSimOverFrequencies(parammgr,SimulationPackage,injdata);
            catch Me
                % Properly restore the model(s) first
                LocalRestoreModel(parammgr,SimulationPackage);
                rethrow(Me);
            end
            % Run each frequency and store results
            if ~SimulationPackage.EstimateAsYouGo
                sineout = cell(1,numel(in.Frequency));
                % Simulate over frequencies
                for ctsine = 1:numel(in.Frequency)
                    [sineout{ctsine},err] = LocalRunSimulationAtFrequency(parammgr,SimulationPackage,injdata,in,rtp,ctsine);
                    if ~isempty(err)
                        LocalHandleErrorSerial(parammgr,SimulationPackage,err);                        
                    end
                end
                % Pack the same outputs together as if sequential
                simout{ctexp} = LocalPackOneAtATimeSinestream(sineout,SimulationPackage.InputSignal,LocalFindInputSampleTime(injdata));
            else
                % If estimate-as-you-go mode is on, do not store the
                % results, compute response and store response.
                for ctsine = 1:numel(in.Frequency)
                    [sineout,err] = LocalRunSimulationAtFrequency(parammgr,SimulationPackage,injdata,in,rtp,ctsine);
                    if isempty(err)
                        resp(:,ctexp,ctsine) = LocalEstimateResponseAtFrequency(sineout,in,ctsine,LocalFindInputSampleTime(injdata)); %#ok<AGROW>
                    else
                        LocalHandleErrorSerial(parammgr,SimulationPackage,err);
                    end
                end
            end                        
        else
            [simout{ctexp},err] = LocalRunSimulation(parammgr,SimulationPackage,ctexp);
            if ~isempty(err)
                LocalHandleErrorSerial(parammgr,SimulationPackage,err);                
            end
        end
    end
    % Restore the model and clean up variables created in the base workspace
    LocalRestoreModel(parammgr,SimulationPackage);
else    
    if distributeOverFreq
        if SimulationPackage.EstimateAsYouGo
            resp = cell(1,numExperiments);
        end        
        for ctexp = 1:numExperiments
            % If rapid sim with one build necessary, perform it at each
            % worker here before sweeping through frequencies
            if SimulationPackage.IsRapidSimWithConstantTsOverFreq
                parfor ct = 1:nWorkers
                    err{ct} = LocalBuildForRapidSimOverFrequenciesOnEachWorker(model,workerVarNames,ctexp);
                end
                % Check if any errors occurred
                [anyErrors,except] = LocalHasAnyErrorOccurredOnWorkers(err);
                if anyErrors
                    % Handle simulation error in parfor
                    LocalRestoreWorkers(model,workerVarNames,nWorkers);
                    rethrow(except);
                end
            end
            numfreq = numel(in.Frequency);
            if ~SimulationPackage.EstimateAsYouGo                
                sineout = cell(1,numfreq);                
                parfor ctsine = 1:numfreq
                    [parammgrw,SimulationPackageW,rptw] = LocalReadSimulationMaterialInWorker(model,workerVarNames);
                    injdata = SimulationPackageW.InjectionDataArray(ctexp).InjectionData;
                    [sineout{ctsine},err{ctsine}] = LocalRunSimulationAtFrequency(parammgrw,SimulationPackageW,injdata,in,rptw,ctsine);
                end
                [anyErrors,except] = LocalHasAnyErrorOccurredOnWorkers(err);
                if anyErrors
                    % Handle simulation error in parfor
                    LocalRestoreWorkers(model,workerVarNames,nWorkers);
                    rethrow(except);
                else
                    simout{ctexp} = LocalPackOneAtATimeSinestream(sineout,SimulationPackage.InputSignal,...
                        LocalFindInputSampleTime(SimulationPackage.InjectionDataArray(ctexp).InjectionData));
                end
            else
                workerBuckets = LocalDistributeFrequenciesAcrossWorkers(numfreq,nWorkers);                
                parfor ctw = 1:nWorkers
                    respThisWorker = {};
                    errThisWorker = {};
                    for ctsine = workerBuckets{ctw}
                        [parammgrw,SimulationPackageW,rptw] = LocalReadSimulationMaterialInWorker(model,workerVarNames);
                        injdata = SimulationPackageW.InjectionDataArray(ctexp).InjectionData;
                        [out,err] = LocalRunSimulationAtFrequency(parammgrw,SimulationPackageW,injdata,in,rptw,ctsine); %#ok<PFTUS>
                        if isempty(err)
                            respThisWorker{ctsine} = LocalEstimateResponseAtFrequency(out,in,ctsine,LocalFindInputSampleTime(injdata));
                            errThisWorker{ctsine} = [];
                        else
                            respThisWorker{ctsine} = [];
                            errThisWorker{ctsine} = err;
                        end
                    end
                    respWorkers{ctw} = respThisWorker;
                    errWorkers{ctw} = errThisWorker;
                end
                % Check if error occurred
                [anyErrors,except] = LocalHasAnyErrorOccurredOnWorkers(errWorkers);
                if anyErrors
                    % Handle simulation error in parfor
                    LocalRestoreWorkers(model,workerVarNames,nWorkers);
                    %Throw one of the errors
                    rethrow(except);
                else                
                    resp{ctexp} = respWorkers;
                end
            end            
        end
        if SimulationPackage.EstimateAsYouGo
            resp = LocalPackResponseFromWorkers(workerBuckets,resp,numfreq);
        end
    else
        
        parfor ctexp = 1:numExperiments
            [parammgrw,SimulationPackageW,~] = LocalReadSimulationMaterialInWorker(model,workerVarNames);
            [simout{ctexp},err{ctexp}] = LocalRunSimulation(parammgrw,SimulationPackageW,ctexp);
        end
        % Check if any errors occurred
        [anyErrors,except] = LocalHasAnyErrorOccurredOnWorkers(err);
        if anyErrors
            % Handle simulation error in parfor
            LocalRestoreWorkers(model,workerVarNames,nWorkers);
            rethrow(except);
        end
    end
    LocalRestoreWorkers(model,workerVarNames,nWorkers);  
end

% Estimate & Label FRD objects
if ~SimulationPackage.EstimateAsYouGo
    sysest = LocalEstimateFrequencyResponse(simout,in,SimulationPackage.InputSignal);
    [sysest.OutputName sysest.InputName] = LocalFRDNames(simout,SimulationPackage.IOTable);
else
    sysest = frd(resp,unitconv(in.Frequency,in.FreqUnits,'rad/s'));
    [sysest.OutputName sysest.InputName] = LocalFRDNamesFromResponse(resp,SimulationPackage.IOTable);
end
% Populate the sample time of FRD result
ts = LocalFRDSampleTime(SimulationPackage.IOTable);
sysest.Ts = ts;

% Return outputs
varargout{1} = sysest;
% Return the simulation output if asked
if numout == 2
    varargout{2} = LocalPackTimeDomainOutput(simout);
end
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalIsConstantTsSinestream
%  Returns true if samples time across all frequencies of a sinestream is
%  fixed
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = LocalIsConstantTsSinestream(in)
if in.FixedTs ~=-2
    bool = true;
    return
else
    % Compute sample times
    ts = 1./unitconv(in.Frequency,in.FreqUnits,'Hz')./in.SamplesPerPeriod;
    bool = (numel(unique(ts)) == 1);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalIsInputSignal
%  Determines if the input argument is a input signal
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = LocalIsInputSignal(in)
bool = false;
if (isa(in,'timeseries') || isa(in,'frest.Sinestream') || isa(in,'frest.Chirp')...
        || isa(in,'frest.Random'))
    bool = true;
end    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalSetupForSimulation
%  Performs the following to prepare the model for simulation:
%  1. Determine the name of variables to create in base workspace
%  2. Determine if rapid accelerator is used and take necessary steps.
%  3. Compute the sample times to write into injection data.
%  4. Construct the injection data.
%  5. Initialize the model with necessary parameters adjusted.
%  6. Write the signals to variables determined.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ModelParameterMgr,SimulationPackage] = LocalSetupForSimulation(model,io,op,in,numout,opts)
% Extract if the input arguments are wrapped in MCOS
if isa(io,'parallelsim.uddWrapper')
    io = io.uddObj;
end
if isa(op,'parallelsim.uddWrapper')
    op = op.uddObj;
end

% Create the model parameter manager
ModelParameterMgr = slcontrol.ModelParameterMgr(model,io);

% Make sure the model is "ready", not "paused" or "running".
if ~strcmp(get_param(model,'SimulationStatus'),'stopped')
    ctrlMsgUtils.error('Slcontrol:frest:InvalidModelStatus',model,model)
end

% Construct the IO table
table = LocalConstructIOTable(io,ModelParameterMgr,opts);
numExperiments = sum(cell2mat(table(:,7)));

% Check consistency of data types and sample times and determine if
% variable sample times will be used.
isVarTs = LocalCheckDataTypeAndSampleTime(table,in,ModelParameterMgr);

% Create the input signals, actual and zeroinput
if isa(in,'timeseries')
    insig = in;
else
    insig = generateTimeseries(in);
end
% Actual input
t = insig.time;u = squeeze(insig.data);
% Create zeroinput input
zeroinput_t = [t(1) t(end)]; zeroinput_u = [0 0];

% Determine input names
names = findVariableNames(ModelParameterMgr,...
                            {'SCD_FRESTIMATE_Actual_Input',...
                             'SCD_FRESTIMATE_Zero_Input',...
                             'SCD_FRESTIMATE_Operating_Point'});                                             
[actinname, zeroinput_inname, op_name] = names{:};

% Write the variables to base workspace
if isVarTs
    assignin('base',actinname,[t(:) u(:)]);
    assignin('base',zeroinput_inname,[zeroinput_t(:) zeroinput_u(:)]);
else
    assignin('base',actinname,u(:));
    assignin('base',zeroinput_inname,zeroinput_u(:));
end
% Determine if the input is OneAtATime Sinestream
isOneAtATimeSinestream = isa(in,'frest.Sinestream') && strcmp(in.SimulationOrder,'OneAtATime');

% Determine if estimation as we run individual simulation can take place,
% this will happen only if the user does not ask for simout.
estimAsYouGo = isOneAtATimeSinestream && (numout < 2);

% Determine if a rapid simulation where one build is enough will be
% performed.
isRapid = strcmp(get_param(ModelParameterMgr.Model,'SimulationMode'),'rapid-accelerator');
isRapidWithFixedTs = isRapid && isOneAtATimeSinestream && LocalIsConstantTsSinestream(in);
maxlen = 0;
if isRapidWithFixedTs    
    % Find the longest frequency
    maxlen = LocalFindLongestFrequency(in);
    % Set the input to be zeros of this size
    assignin('base',actinname,zeros(maxlen,1));
    % Make those variables tunable in the model(s)
    ModelParameterMgr = ModelParameterMgr.prepareTunableParameters(...
        sprintf('%s,%s',actinname,zeroinput_inname));
    want.InlineParams = 'on';
end


% Compute the actual sample time to put in the injection data
if isa(in,'frest.Sinestream') && (in.FixedTs ~= -2)
    actTs = in.FixedTs;
else
    actTs = t(2)-t(1);
end

% Construct injdataArray
injdataArray = LocalConstructInjectionDataArray(table,actinname,zeroinput_inname,isVarTs,actTs);

% Prepare the model
want.AnalyticLinearization = 'off';
want.UseAnalysisPorts = 'off';
want.SignalBasedLinearization = 'on';
want.CompileForInfoOnSignalBasedLinearization = 'off';

% Initialize the model with operating point
simopts = simset('ReturnWorkspaceOutputs','on');
simut = []; op_used = false;
if ~isempty(op)
    op_used = true;
    % Write the operating point to the model workspace
    assignin(get_param(ModelParameterMgr.Model,'ModelWorkspace'),op_name,op);    
    want.LoadInitialState = 'on';   
    want.InitialState = sprintf('getstatestruct(%s)',op_name);
    simut = getinputstruct(op);
end
try
    ModelParameterMgr.prepareParameters('ModelParameters',want);
catch Me
    LocalRestoreModel(ModelParameterMgr);
    rethrow(Me);
end


% Return the necessary output that will be used later in a structure
SimulationPackage = struct('NumberOfExperiments',numExperiments,...
                           'IsOneAtATimeSinestream',isOneAtATimeSinestream,...
                           'IOTable',{table},...
                           'FinalTime',t(end),...
                           'InputSignal',insig,...
                           'InjectionDataArray', injdataArray,...
                           'SimulationOptions', simopts,...
                           'SimulationInitialInput', simut,...
                           'IsRapidAccel',isRapid,...
                           'IsRapidSimWithConstantTsOverFreq', isRapidWithFixedTs,...
                           'MaxInputLength', maxlen,...
                           'ActiveInputName', actinname,...
                           'ZeroInputName', zeroinput_inname,...
                           'OperatingPointName', op_name,...
                           'OperatingPointUsed', op_used,...
                           'EstimateAsYouGo',estimAsYouGo);                           
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCheckDataTypeAndSampleTime
%  Checks if the necessary conditions around data type and sample time of
%  the signals where IOs are placed and its compatibility with input sample
%  time are satisfied. Also computes if variable sample time will be used
%  for the simulation and sample time values to be placed in injectiondata.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isVarTs = LocalCheckDataTypeAndSampleTime(table,in,ModelParameterMgr)
% Check if all input/output is on double signals
ind = find(strcmp(table(:,3),'Input') | strcmp(table(:,3),'Output') | strcmp(table(:,3),'Both'));
for ct = ind'
    if ~isequal(table{ct,4}.DataType,0)
        ModelParameterMgr.restoreModel;
        ctrlMsgUtils.error('Slcontrol:frest:NonDoubleInOutIO',ct)
    end        
end

% Find the sample time of the signal, there might be many for
% sinestream
if isa(in,'frest.Sinestream') 
    if (in.FixedTs == -2)
        tsin = 1./unitconv(in.Frequency,in.FreqUnits,'Hz')./in.SamplesPerPeriod;
        tsin = unique(tsin);
    else
        tsin = in.FixedTs;
    end
elseif isa(in,'frest.Chirp') || isa(in,'frest.Random')
    tsin = in.Ts;
else
    % Custom input - check that uniformly sampled
    intimeint = diff(in.Time);
    if max(intimeint-intimeint(1)) > sqrt(eps)
        ModelParameterMgr.restoreModel;
        ctrlMsgUtils.error('Slcontrol:frest:NoUniformCustom')
    end
    tsin = intimeint(1);
end

% Check that all input IOs are either Ts = 0 or FiM or a discrete
% rate that is the same as the input signal's
ind = find(strcmp(table(:,3),'Input') | strcmp(table(:,3),'Both'));
for ct = ind'
    tssig = table{ct,4}.SampleTime;
    if numel(tsin) > 1
        % Sinestream with many sample times
        if ~(isequal(tssig(1),0))
            ModelParameterMgr.restoreModel;
            ctrlMsgUtils.error('Slcontrol:frest:IncompatibleIOTsSinestream',ct,ct);
        end        
    else
        % Unique sample rate
        if ~(isequal(tssig(1),0) || (tsin == tssig(1)))
            ModelParameterMgr.restoreModel;
            ctrlMsgUtils.error('Slcontrol:frest:IncompatibleIOTs','input',ct,ct);
        end
    end
end
% Check that all output IOs are either Ts = 0 or FiM or a discrete
% rate that is the same as the input signal's
ind = find(strcmp(table(:,3),'Output'));
for ct = ind'
    tssig = table{ct,4}.SampleTime;
    if numel(tsin) > 1
        % Sinestream with many sample times
        if ~(isequal(tssig(1),0))
            ModelParameterMgr.restoreModel;
            ctrlMsgUtils.error('Slcontrol:frest:IncompatibleIOTsSinestream',ct,ct);
        end
    else
        % Unique sample rate
        if ~(isequal(tssig(1),0) || (tsin == tssig(1)))
            ModelParameterMgr.restoreModel;
            ctrlMsgUtils.error('Slcontrol:frest:IncompatibleIOTs','output',ct,ct);
        end
    end
end

% Determine variable sample is going to be used for simulation. The conditions
% are:
% 1. The input signal should be a sinestream with more than one sample time
% and SimulationOrder is sequential
% 2. The model should have variable-step solver.
% 3. None of the input I/O should be located in normal mode model
% references.
% 4. All input and output IO should be on Ts = 0 or FiM, but this is
% already checked above.

isVarTs = false;
if numel(tsin) > 1 && strcmp(in.SimulationOrder,'Sequential')
    % Error out if the input signal is a sequential sinestream but you cannot
    % use variable sample time, along with the reason    
    isVarTs = true;
    % Check the solver
    if ~strcmp(get_param(ModelParameterMgr.Model,'SolverType'),'Variable-step')
        ModelParameterMgr.restoreModel;
        ctrlMsgUtils.error('Slcontrol:frest:UnableToRunSequentialSolver',...
            ModelParameterMgr.Model, ModelParameterMgr.Model)             
    end
    % Check model referencing condition
    ind = find(strcmp(table(:,3),'Input') | strcmp(table(:,3),'Both'));
    for ct = ind'
        % Get the parent model of input IO
        parentmdl = get(getModelHandleFromBlock(slcontrol.Utilities, table{ct,1}.Block),'Name');
        % Error if it is not the parent model
        if ~strcmp(parentmdl,ModelParameterMgr.Model)
            ModelParameterMgr.restoreModel;
            ctrlMsgUtils.error('Slcontrol:frest:InputIOInModelRef',...
                ModelParameterMgr.Model,table{ct,1}.Block, parentmdl);
        end
    end
    
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFindLongestFrequency
%  Finds and returns the length of the frequency with the most samples in
%  it.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxlen = LocalFindLongestFrequency(in)
% Scalar expand one if all NumPeriods,RampPeriods and SamplesPerPeriod are
% scalar
if isscalar(in.NumPeriods) && isscalar(in.RampPeriods) && isscalar(in.SamplesPerPeriod)
    numP = in.NumPeriods*ones(size(in.Frequency));
else
    numP = in.NumPeriods;
end
freqlengths = (numP+in.RampPeriods).*in.SamplesPerPeriod;
maxlen = max(freqlengths);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalConstructInjectionDataArray
%  Create the injection data array for all experiments that will be run
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function injdataArray = LocalConstructInjectionDataArray(table,actinname,zeroinput_inname,isVarTs,actTs)
% First get the total number of experiment, i.e. total input channels
numexp = sum(cell2mat(table(:,7)));
% Initialize the array
% Signal injection data
siginjdata = struct('IOType','','DataType','','Dimensions','',...
                    'PortDataSize','','SampleTime','',...
                    'BusSignalName','','SignalIndex','',...
                    'IsVariableTs',mat2str(double(isVarTs)),'InputSampleTime','');
% Injection data
injdata = struct('PortHandle','','InputWKSVariable','',...
                 'OutputWKSVariable','','SignalInjectionData',siginjdata);
injdata = repmat(injdata,1,size(table,1));             
% Injection data array
injdataArray.InjectionData = injdata;
injdataArray = repmat(injdataArray,1,numexp);
% Process the input IOs and populate fields in injection data array
ind = find(strcmp(table(:,3),'Input') | strcmp(table(:,3),'Both'));
curindex = 1;
for ctio = ind'
    % Process this input IO for all channels
    for ctch = 1:table{ctio,7}
        for ctallio = 1:size(table,1)            
            if ctallio == ctio
                % This is the current input IO
                % First transfer info from insertioninfo in the table
                if strcmp(get(table{ctallio,1},'Type'),'in')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'Input';
                elseif strcmp(get(table{ctallio,1},'Type'),'inout')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'InputOutput';
                elseif strcmp(get(table{ctallio,1},'Type'),'outin')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'OutputInput';
                end
                if strcmp(get(table{ctallio,1},'OpenLoop'),'on')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = ...
                        sprintf('%sOpen',injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType);
                end
                % Write the actual input signal name
                injdataArray(curindex).InjectionData(ctallio).InputWKSVariable = actinname;
                % Write the signal index
                injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.SignalIndex = ...
                    mat2str(ctch);
                % Write the actual input signal sample time
                injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.InputSampleTime = ...
                    mat2str(actTs);
            else
                % This is one of the other IOs
                % Input Type
                if strcmp(get(table{ctallio,1},'Type'),'in')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'InputInactive';
                elseif strcmp(get(table{ctallio,1},'Type'),'out')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'Output';
                elseif strcmp(get(table{ctallio,1},'Type'),'inout')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'InputOutputInactive';
                elseif strcmp(get(table{ctallio,1},'Type'),'outin')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'OutputInputInactive';
                else
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = 'Open';
                end
                if any(strcmp(get(table{ctallio,1},'Type'),{'in','out','inout','outin'})) && strcmp(table{ctallio,1}.OpenLoop,'on')
                    injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType = ...
                        sprintf('%sOpen',injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IOType);
                end
                % Write the zero input name
                injdataArray(curindex).InjectionData(ctallio).InputWKSVariable = zeroinput_inname;
                % Write the signal index as 1, it wont be honored in any
                % case.
                injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.SignalIndex = ...
                    mat2str(1);
                % Write the zero input sample time to be inf
                injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.InputSampleTime = ...
                    mat2str(inf);
                % Set the variable sample time usage to false
                injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.IsVariableTs = ...
                    mat2str(0);
            end
            % Carry common information
            injdataArray(curindex).InjectionData(ctallio).PortHandle = table{ctallio,2};
            injdataArray(curindex).InjectionData(ctallio).OutputWKSVariable = table{ctallio,5};            
            injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.DataType = ...
                mat2str(table{ctallio,4}.DataType);
            injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.Dimensions = ...
                mat2str(table{ctallio,4}.Dimensions);
            injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.PortDataSize = ...
                mat2str(table{ctallio,4}.PortDataSize);
            injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.SampleTime = ...
                mat2str(table{ctallio,4}.SampleTime);
            injdataArray(curindex).InjectionData(ctallio).SignalInjectionData.BusSignalName = ...
                table{ctallio,4}.BusSignalName;
            
        end      
        curindex = curindex+1;
    end
end


end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalConstructIOTable
%  Construct the table which is a cell array that has as many rows as the
%  number of IOs and seven columns for
%  IO,PortHandle,Type,InsertionInfo,LoggingName,NameinSimout,
%  NumInputElements
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table = LocalConstructIOTable(io,ModelParameterMgr,opts)

model = ModelParameterMgr.Model;
% Append source blocks to hold constant to the end of existing io as open
% loop points
if ~isempty(opts.BlocksToHoldConstant)
    for ct = 1:numel(opts.BlocksToHoldConstant)
        % Get number of output ports
        blk = opts.BlocksToHoldConstant(ct).convertToCell;
        try
            ph = get_param(blk{end},'PortHandles');
        catch Me
            ctrlMsgUtils.error('Slcontrol:frest:NonExistingBlockToHoldConstant',model);
        end
        % Check if this block is already specified in an I/O
        ioind = [];
        for ctio = 1:numel(io)
            if strcmp(blk{1},io(ctio).Block)
                ioind = ctio;
                break;
            end
        end
        for ctp = 1:numel(ph.Outport)
            if ~isempty(ioind) && (io(ioind).PortNumber == ctp)
                % Modify that io to be an open loop
                io(ioind).OpenLoop = 'on';
            else
                io(end+1).Block = blk{end}; %#ok<AGROW>
                io(end).PortNumber = ctp;
                io(end).Type = 'none';
                io(end).OpenLoop = 'on';
            end
        end           
    end
end
table = cell(numel(io),7);
util = slcontrol.Utilities;

% Construct the table
for ct = 1:numel(io)
    table{ct,1} = io(ct);
    % Get the port handle
    try
        ph = get_param(io(ct).Block,'PortHandles');
    catch Me
        ctrlMsgUtils.error('Slcontrol:frest:InvalidIO',model);
    end
    table{ct,2} = ph.Outport(io(ct).PortNumber);
    % Make sure that this block is connected to another Simulink block.
    lh = get_param(table{ct,2},'Line');
    if isequal(lh,-1) || isequal(get_param(lh,'DstPortHandle'),-1)
        ctrlMsgUtils.error('Slcontrol:frest:UnconnectedIO',...
            model,io(ct).Block,ct);  
    end    
    % Populate type
    switch io(ct).Type
        case 'in'
            table{ct,3} = 'Input';            
        case 'out'
            table{ct,3} = 'Output';
            table{ct,7} = 0;
        case {'inout', 'outin'}
            table{ct,3} = 'Both';
        otherwise
            table{ct,3} = 'None';
            table{ct,7} = 0;
    end
    % Populate logging name based on temporary naming
    table{ct,5} = strrep(tempname,tempdir,'');
    % Construct NameinSimout
    % If there is a signal name, use it, otherwise use truncated block name
    if ~isempty(get_param(table{ct,2},'Name'))        
        name = getUniqueSignalName(util,table{ct,2},ModelParameterMgr);        
    else
        name = getUniqueBlockName(util,io(ct).Block,ModelParameterMgr);
        % Add port number if the block has multiple outports
        if numel(ph.Outport) > 1
            name = sprintf('%s/%d',name,io(ct).PortNumber);
        end        
    end
    table{ct,6} = name;
end

% Make sure that there is at least one input and one output IO
if ~(any(strcmp(table(:,3),'Both')) || (any(strcmp(table(:,3),'Input')) && any(strcmp(table(:,3),'Output'))))
    ctrlMsgUtils.error('Slcontrol:frest:NoInputOutputIO',model)    
end


% Get the insertion info
want.CompileForInfoOnSignalBasedLinearization = 'on';
want.AnalyticLinearization = 'off';
want.UseAnalysisPorts = 'off';
want.SignalBasedLinearization = 'off';
try
    ModelParameterMgr.prepareModel('ModelParameters',want,'LinearizationIO',io);
catch Me
    ModelParameterMgr.restoreModel;
    % Check to see if IO matches the model and is valid.
    if strcmp(Me.identifier,'Slcontrol:linearize:InvalidIO')     
        ctrlMsgUtils.error('Slcontrol:frest:InvalidIO',model)        
    else
        rethrow(Me)
    end        
end
% Distribute the injection data
injdata = cell2mat(table(:,2));
% Convert injdata to row
injdata = injdata(:)';
% Run engine interface method
insertioninfo = ModelParameterMgr.getInsertionInfo(injdata);

% Place insertion info in the table
ph_info = cell2mat({insertioninfo(:).PortHandle});
% Make sure that no bus signal exists
if numel(ph_info) ~= numel(unique(ph_info))
    ModelParameterMgr.restoreModel;
    ctrlMsgUtils.error('Slcontrol:frest:NoBusIOAllowed')        
end
for ct = 1:numel(injdata)
    table{ct,4} = insertioninfo(ph_info == injdata(ct));
    % Populate number of input elements
    if isempty(table{ct,7})
        dims = table{ct,4}.Dimensions;
        table{ct,7} = prod(dims(2:end));
    end
end

% Refresh the model parameter manager as engine interface method has
% executed.
ModelParameterMgr.restoreParameters;

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalRunSimulationAtFrequency
%  Run simulation for the specified frequency in a Sinestream (used in
%  OneAtATime case)
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sineout,err] = LocalRunSimulationAtFrequency(ModelParameterMgr,SimulationPackage,injdata,in,rtp,f_index)
err = [];
insig = SimulationPackage.InputSignal;
table = SimulationPackage.IOTable;
% Rewrite variables
insigthisfreq = frest.frestutils.pickFrequencyFromSinestream(in,f_index,insig);
u = squeeze(insigthisfreq.data);
% Zeropad if necessary
maxlen = SimulationPackage.MaxInputLength;
if SimulationPackage.IsRapidSimWithConstantTsOverFreq && (numel(u) < maxlen)
    u(end+1:maxlen) = 0;
end
assignin('base',SimulationPackage.ActiveInputName,u(:));
% Update actual and zeroinput_ ts if sample time is not
% constant over frequencies
if ~SimulationPackage.IsRapidSimWithConstantTsOverFreq
    actTs = insigthisfreq.time(2)-insigthisfreq.time(1);
    injdata = LocalUpdateInjectionData(injdata,actTs);
    % Distribute updated injection data among referenced models
    ModelParameterMgr.distributeInjectionData(injdata);
else
    % Update tunable parameters    
    tunparams = Simulink.BlockDiagram.modifyTunableParameters(rtp,...
        SimulationPackage.ActiveInputName,evalin('base',SimulationPackage.ActiveInputName),...
        SimulationPackage.ZeroInputName,evalin('base',SimulationPackage.ZeroInputName));
    % Specify that sim command does not check model update
    SimulationPackage.SimulationOptions = simset(SimulationPackage.SimulationOptions,...
        'RapidAcceleratorUpToDateCheck','off',...
        'RapidAcceleratorParameterSets',tunparams);    
end
% Simulate
try
    simresults = sim(ModelParameterMgr.Model,insigthisfreq.time(end),...
        SimulationPackage.SimulationOptions,SimulationPackage.SimulationInitialInput);
    % Accumulate outputs as if sequential
    sineout = LocalStoreOneAtATimeSinestream(simresults,table,insigthisfreq.time(:));
catch Me
    err.Exception = Me;
    err.Ts = LocalFindInputSampleTime(injdata);
    sineout = [];
    return;
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalUpdateInjectionData
%  Updates an injectionData with a new actual and zeroinput input samples
%  times. Use for the case of OneAtATime sinestream 
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function injdata = LocalUpdateInjectionData(injdata,actTs)
for ct = 1:numel(injdata)
    if any(strcmp(injdata(ct).SignalInjectionData.IOType,...
            {'Input','OutputInput','InputOutput','InputOpen','OutputInputOpen','InputOutputOpen'}))
        injdata(ct).SignalInjectionData.InputSampleTime = mat2str(actTs);
    else
        injdata(ct).SignalInjectionData.InputSampleTime = mat2str(inf);
    end    
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalRunSimulation
%  Run the simulation
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output,err] = LocalRunSimulation(ModelParameterMgr,SimulationPackage,exp_index)
err = [];
% Extract necessary information from SimulationPackage
% Get injection data for current experiment
injdata = SimulationPackage.InjectionDataArray(exp_index).InjectionData;
% Find the sample time of the original input signal in the model
insigts = LocalFindInputSampleTime(injdata);


distributeInjectionData(ModelParameterMgr,injdata);
% Simulate the system
try
    simresults = sim(ModelParameterMgr.Model,SimulationPackage.FinalTime,...
        SimulationPackage.SimulationOptions,SimulationPackage.SimulationInitialInput);
    % Store the outputs
    output = LocalStoreOutputs(simresults,SimulationPackage.IOTable,SimulationPackage.InputSignal.time(:),insigts);
catch Me
    err.Exception = Me;
    err.Ts = insigts;
    output = [];
    return;
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFindInputSampleTime
%  Returns the sample time of original signal in Simulink for the input
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function insigts = LocalFindInputSampleTime(injdata)
insigts = [0 0];
for ct = 1:length(injdata)
    if any(strcmp(injdata(ct).SignalInjectionData.IOType,...
            {'Input','OutputInput','InputOutput','InputOpen','OutputInputOpen','InputOutputOpen'}))
        insigts = eval(injdata(ct).SignalInjectionData.SampleTime);
        return;
    end    
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalRestoreModel
%  Perform command actions before reporting the issues in
%  frestimate-specific way
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRestoreModel(ModelParameterMgr,varargin)
% Restore the model
models = [ModelParameterMgr.Model;ModelParameterMgr.NormalRefModels];
for ct = 1:numel(models)
    set_param(models{ct},'InjectionData',[]);
end
% Clean up variables created in the base workspace if requested
if nargin > 1    
    LocalCleanUpVariables(ModelParameterMgr,varargin{1});
end
ModelParameterMgr.restoreModel;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCleanUpVariables
%  Cleans up the variables created in the base and model workspace
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCleanUpVariables(parammgr,SimulationPackage)
% Clean up the variables from base workspace
evalin('base',sprintf('clear %s',SimulationPackage.ActiveInputName));
evalin('base',sprintf('clear %s',SimulationPackage.ZeroInputName));
if SimulationPackage.OperatingPointUsed
    evalin(get_param(parammgr.Model,'ModelWorkspace'),sprintf('clear %s',SimulationPackage.OperatingPointName));    
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalHandleRateTransitionError
%  Report the issue properly if a rate transition has occurred.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHandleRateTransitionError(Me)
[errids ~] = slprivate('getAllErrorIdsAndMsgs', Me);
if any(strcmp(errids,'Simulink:SampleTime:IllegalIPortRateTrans'))
    ctrlMsgUtils.error('Slcontrol:frest:IncompatibleTsFixedStep');
elseif any(strcmp(errids,'Simulink:SampleTime:ComputedStepSizeIsTooSmall'))
    ctrlMsgUtils.error('Slcontrol:frest:IncompatibleTsFixedStep2');
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalReportOutofMemoryErrors
%  Report the issue properly if it is about running out of memory
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalReportOutofMemoryErrors(Me)
[errids ~] = slprivate('getAllErrorIdsAndMsgs', Me);
if (any(strcmp(errids,'Simulink:Logging:LoggingMallocError')) || ...
    any(strcmp(errids,'Simulink:Logging:LoggingExceededMemoryLimitErr')) || ...
    any(strcmp(errids,'MATLAB:nomem')))    
        ctrlMsgUtils.error('Slcontrol:frest:OutOfMemory');
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalHandleErrorSerial
%  Process and report the error in non-parfor cases
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHandleErrorSerial(ModelParameterMgr,SimulationPackage,Me)
% If your model is fixed step solver and IOs are continuous
% and you received rate transition errors, error properly.
% Check this here before restoring the model as the model might
% get closed later on.
insigts = Me.Ts;
isRateProblemCandidate = (strcmp(get_param(ModelParameterMgr.Model,'SolverType'),'Fixed-step') && isequal(insigts(1),0));

% Properly restore the model(s) first
LocalRestoreModel(ModelParameterMgr,SimulationPackage);

% Properly report out of memory issues
LocalReportOutofMemoryErrors(Me.Exception)

if isRateProblemCandidate
    LocalHandleRateTransitionError(Me.Exception);
end
rethrow(Me.Exception);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalStoreOutputs
%  Stores the output of a given experiments in a convenient format to be
%  later processed for frequency response estimation. The format is a
%  structure array which is as long as the number of output IOs and each
%  element in this structure has two fields: Output and OutputSignalTs. Output is
%  the Simulink.Timeseries object and OutputSignalTs is the sample time of the
%  signal in Simulink model where this output IO is located.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = LocalStoreOutputs(simresults,table,timevector,insigts)
ind = find(strcmp(table(:,3),'Output') | strcmp(table(:,3),'Both'));
out = struct('Output',1:numel(ind));
out_index = 1;
for ct = ind'
    raw_output = simresults.find(table{ct,5});
    raw_output = LocalFilterExtraTimeSteps(raw_output,timevector);
    processed_output.Data = raw_output.signals.values;
    processed_output.SignalDimensions = raw_output.SignalDimensions;
    processed_output.Time = timevector;
    processed_output.BlockPath = table{ct,1}.Block;
    processed_output.PortIndex = table{ct,1}.PortNumber;
    processed_output.SignalName = get_param(table{ct,2},'Name');
    processed_output.Name = table{ct,6};
    out(out_index).Output = processed_output;
    % Sample time is necessary to account for ZOH effect in the frequency
    % response estimation
    out(out_index).OutputSignalTs = table{ct,4}.SampleTime;
    out(out_index).InputSignalTs = insigts;
    out_index = out_index +1;
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalStoreOneAtATimeSinestream
%  Stores the result of a given experiment (frequency) for OneAtATime
%  sinestream to be recomposed later in LocalPackOneAtATimeSinestream
%  function.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = LocalStoreOneAtATimeSinestream(simresults,table,timevector)
ind = find(strcmp(table(:,3),'Output') | strcmp(table(:,3),'Both'));
out = cell(1,numel(ind));
out_index = 1;
for ct = ind'
    raw_output = simresults.find(table{ct,5});
    raw_output = LocalFilterExtraTimeSteps(raw_output,timevector);
    % Note that there is no need to store time here as it will be
    % recomposed as if sequential eventually.
    out{out_index}.Data = raw_output.signals.values;
    out{out_index}.SignalDimensions = raw_output.SignalDimensions;
    out{out_index}.BlockPath = table{ct,1}.Block;
    out{out_index}.PortIndex = table{ct,1}.PortNumber;
    out{out_index}.SignalName = get_param(table{ct,2},'Name');
    out{out_index}.Name = table{ct,6};
    out{out_index}.OutputSignalTs = table{ct,4}.SampleTime;
    out_index = out_index + 1;
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalPackOneAtATimeSinestream
%  Packs together the results of a given OneAtATime sinestream bringing the
%  results for each frequency together and convert the result in a format
%  similar to sequential sinestream.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function simout = LocalPackOneAtATimeSinestream(sineout,insig,insigts)
simout = struct('Output',1:numel(sineout{1}));
for ctout = 1:numel(sineout{1})
    thisoutput = sineout{1}{ctout};
    % Find out if time dimension is first in original data
    isTimeFirst = (size(thisoutput.Data,1) ~=thisoutput.SignalDimensions(1));
    % Combine signals with time dimension first
    composeddata = zeros([numel(insig.data) thisoutput.SignalDimensions]);
    composed_index = 1;
    for ctf = 1:numel(sineout)
        % Find number of time samples in this frequency
        addedLen = setdiff(size(sineout{ctf}{ctout}.Data),thisoutput.SignalDimensions);
        % Get data with time dimension first
        thisfreqdata = LocalGetData(sineout{ctf}{ctout}.Data,addedLen);
        composeddata(composed_index:composed_index+addedLen-1,:) = ...
            thisfreqdata(1:addedLen,:);
        composed_index = composed_index+addedLen;
    end
    % Restore time dimension location
    if ~isTimeFirst
        finalshape = [thisoutput.SignalDimensions numel(insig.data)];
        composeddata = reshape(shiftdim(composeddata,1),finalshape);
    end
    processed_output.Data = composeddata;
    processed_output.SignalDimensions = thisoutput.SignalDimensions;
    processed_output.Time = insig.time;
    processed_output.BlockPath = thisoutput.BlockPath;
    processed_output.SignalName = thisoutput.SignalName;
    processed_output.PortIndex = thisoutput.PortIndex;
    processed_output.Name = thisoutput.Name;    
    simout(ctout).Output = processed_output;
    % Sample time is necessary to account for ZOH effect in the frequency
    % response estimation
    simout(ctout).OutputSignalTs = thisoutput.OutputSignalTs;
    simout(ctout).InputSignalTs = insigts;
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalPackTimeDomainOutput
%  Packages the simulation output data as a cell matrix of
%  Simulink.Timeseries objects where the number of columns is equal to
%  total input channels (which is also equal to total number of
%  simulations) and the number of rows is the number of output IOs (not
%  channels)
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = LocalPackTimeDomainOutput(simout)
numin = numel(simout);
numoutio = numel(simout{1});
out = cell(numoutio,numin);
for ctin = 1:numin    
    for ctoutio = 1:numoutio
        % Get the current output as a structure
        curout = simout{ctin}(ctoutio).Output;
        % Create the Simulink.Timeseries object out of the structure
        simTs = Simulink.Timeseries;
        data = curout.Data;
        simTs.IsTimeFirst = (ndims(data) == 2);
        simTs.Data = data;
        simTs.Time = curout.Time;
        simTs.BlockPath = curout.BlockPath;
        simTs.PortIndex = curout.PortIndex;
        simTs.SignalName = curout.SignalName;
        simTs.Name = curout.Name;        
        out{ctoutio,ctin} = simTs;
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFilterExtraTimeSteps
%  Simulink is likely to take some extra time step apart from the samples
%  of input signals and this function removes those extra time steps in the
%  output and make the input and outputs(s) to be aligned in time.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = LocalFilterExtraTimeSteps(out,timevector)
% Store signal dimensions first
out.SignalDimensions = out.signals.dimensions;
% If lengths are equal, no need to filter
if (numel(out.time(:))== numel(timevector))
    return;
end
% Filtering is required

% First convert the data to time dimension first since it is easier to
% erase a time sample in that format
isTimeFirst = (size(out.signals.values,1) ~=out.SignalDimensions(1));
data = LocalGetData(out.signals.values,numel(out.time));

% Initialize the new indices, making sure time & corresponding data is
% unique -g531157
[time,unique_ind,~] = unique(out.time);
time = time(:);
data = data(unique_ind,:);

% Find indices corresponding to expected time instances
y = 1:numel(time);
ind_new = interp1(time,y,timevector(:),'nearest','extrap');

% Filter out other values
data = data(ind_new,:);
out.time = out.time(ind_new);

% Reshape data if time was not first originally
if ~isTimeFirst
    finalshape = [out.SignalDimensions size(data,1)];
    data = reshape(shiftdim(data,1),finalshape);
end
out.signals.values = data;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalGetData
%  Get the data with time dimension first for estimation or intermediate
%  processing purposes.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = LocalGetData(data,numtimesteps)
if ~(size(data,1) == numtimesteps)
    % Use shiftdim to bring the time to the first dimension
    shift = ndims(data)-1;
    out = shiftdim(data,shift);    
else
    out = data;
end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalEstimateResponseAtFrequency
%  Estimates the frequency response for the specified frequency and returns
%  the response (used in Estimate-As-You-Go) case.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resp = LocalEstimateResponseAtFrequency(sineout,in,ctsine,insigts)
% Find out where frequencies are switched and points after settling time
[freqswitchpoints,ssswitchpoints] = computeSwitchPoints(in);
% Get relevant frequency of the input
insig = in.generateTimeseries;
if ctsine == 1
    insig = squeeze(insig.Data(1:freqswitchpoints(ctsine)));
    ssOffset = ssswitchpoints(ctsine);
else
    insig = squeeze(insig.Data(1+freqswitchpoints(ctsine-1):...
        freqswitchpoints(ctsine)));
    ssOffset = ssswitchpoints(ctsine)-freqswitchpoints(ctsine-1);    
end
% Find the number of IOs and channels in the output
numoutio = numel(sineout);
numoutch = 0;
for ctout = 1:numoutio
    numoutch = numoutch+prod(sineout{ctout}.SignalDimensions);    
end
% Pre allocate response for each output channel
resp = zeros(1,numoutch);
thisFreq = unitconv(in.Frequency(ctsine),in.FreqUnits,'rad/s');
thisSamplesPerPeriod = in.SamplesPerPeriod;
if ~isscalar(thisSamplesPerPeriod)
    thisSamplesPerPeriod = thisSamplesPerPeriod(ctsine);
end
tssig = 2*pi./thisFreq./thisSamplesPerPeriod;
% Design the filter & remove the transients from input
if strcmp(in.ApplyFilteringInFRESTIMATE,'on')
    % Design a derivative x bandpass x low pass filter
    filt = in.designFIRFilter(tssig,thisSamplesPerPeriod);
    % Filter input and remove transients
    insig = filter(filt,1,insig);
    insig = insig(ssOffset+1+thisSamplesPerPeriod:end);
else
    insig = insig(ssOffset+1:end);
end
output_index = 1;
for ctio = 1:numoutio   
    numsamples = setdiff(size(sineout{ctio}.Data),sineout{ctio}.SignalDimensions);
    outThisIO = LocalGetData(sineout{ctio}.Data,numsamples);
    tsoutio = sineout{ctio}.OutputSignalTs;    
    numchthisio = prod(sineout{ctio}.SignalDimensions);
    for ctch = 1:numchthisio
        out = outThisIO(:,ctch);
        % Run the filter                        
        if strcmp(in.ApplyFilteringInFRESTIMATE,'on')
            % Run the filter on the signal
            out = filter(filt,1,out);            
            % Remove the transients
            out = out(ssOffset+1+thisSamplesPerPeriod:end);            
        else
            out = out(ssOffset+1:end);            
        end
        % Compute FFT
        NFFTThisFreq = numel(out);
        indexThisFreq = 1+round(NFFTThisFreq/thisSamplesPerPeriod);
        respThisFreq = fft(out(:),NFFTThisFreq)./fft(insig(:),NFFTThisFreq);
        % If original source of signal is of continuous, take
        % ZOH effect into account.
        respThisFreq = respThisFreq(indexThisFreq);
        if isequal(tsoutio(1),0) && isequal(insigts(1),0)
            zohThisFreq = (1-exp(-1i*thisFreq*tssig))/(1i*thisFreq*tssig);
            respThisFreq = respThisFreq./zohThisFreq;
        end
        resp(output_index) = respThisFreq;
        output_index = output_index +1;
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalEstimateFrequencyResponse
%  Estimates the frequency response and returns the FRD object given the
%  outputs and input signal.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sysest = LocalEstimateFrequencyResponse(simout,in,insig)
numin = numel(simout);
numoutch = LocalFindTotalNumberOfOutputChannels(simout);
numoutio = numel(simout{1});
if isa(in,'frest.Sinestream')
    freq = unitconv(in.Frequency,in.FreqUnits,'rad/s');
    % Find out where frequencies are switched and points after settling time
    [freqswitchpoints,ssswitchpoints] = computeSwitchPoints(in);
    resp = zeros(numoutch,numin,numel(freq));
    % Scalar expand samplesPerPeriod
    samps = in.SamplesPerPeriod;
    if isscalar(samps)
        samps = repmat(samps,size(freq));        
    end
    for ctin = 1:numin
        cur_out_ind = 1;        
        for ctout = 1:numoutio
            % Find number of channels in this IO
            numtimesteps = numel(simout{ctin}(ctout).Output.Time(:));
            out = LocalGetData(simout{ctin}(ctout).Output.Data,numtimesteps);
            tsoutio = simout{ctin}(ctout).OutputSignalTs;
            tsinio = simout{ctin}(ctout).InputSignalTs;
            numchthisio = prod(simout{ctin}(ctout).Output.SignalDimensions);
            for ctch = 1:numchthisio                
                for ct = 1:numel(freq)
                    % Capture data for the current frequency
                    % This portion includes
                    if ct == 1                        
                        outThisFreq = squeeze(out(1:...
                            freqswitchpoints(ct),ctch));
                        % Corresponding input portion
                        inThisFreq = squeeze(insig.Data(1:...
                            freqswitchpoints(ct)));
                        ssOffset = ssswitchpoints(ct);
                    else
                        outThisFreq = squeeze(out(1+freqswitchpoints(ct-1):...
                            freqswitchpoints(ct),ctch));
                        % Corresponding input portion
                        inThisFreq = squeeze(insig.Data(1+freqswitchpoints(ct-1):...
                            freqswitchpoints(ct)));
                        ssOffset = ssswitchpoints(ct)-freqswitchpoints(ct-1);
                    end
                    tssig = 2*pi./freq(ct)./samps(ct);
                    if strcmp(in.ApplyFilteringInFRESTIMATE,'on')
                        % Design a derivative x bandpass x low pass filter
                        filt = in.designFIRFilter(tssig,samps(ct));
                        % Run the filter on the signal
                        outThisFreq = filter(filt,1,outThisFreq);
                        inThisFreq = filter(filt,1,inThisFreq);
                        % Remove the transients
                        outThisFreq = outThisFreq(ssOffset+1+samps(ct):end);
                        inThisFreq = inThisFreq(ssOffset+1+samps(ct):end);
                    else
                        outThisFreq = outThisFreq(ssOffset+1:end);
                        inThisFreq = inThisFreq(ssOffset+1:end);                      
                    end
                    % Compute FFT
                    NFFTThisFreq = numel(outThisFreq);                                        
                    indexThisFreq = 1+round(NFFTThisFreq/samps(ct));                    
                    respThisFreq = fft(outThisFreq(:),NFFTThisFreq)./fft(inThisFreq(:),NFFTThisFreq);
                    % If original source of signal is of continuous, take
                    % ZOH effect into account.
                    respThisFreq = respThisFreq(indexThisFreq);
                    if isequal(tsoutio(1),0) && isequal(tsinio(1),0)
                        zohThisFreq = (1-exp(-1i*freq(ct)*tssig))/(1i*freq(ct)*tssig);
                        respThisFreq = respThisFreq./zohThisFreq;
                    end                    
                    resp(cur_out_ind,ctin,ct) = respThisFreq;
                end
                cur_out_ind = cur_out_ind + 1;
            end            
        end
    end
    sysest = frd(resp,freq);  
else
    % JUST RETURN FFT(OUT)/FFT(IN)
    NFFT = numel(insig.Data);
    ts = insig.Time(2) - insig.Time(1);
    % Handle when NFFT is odd
    if rem(NFFT,2)
        % Odd
        freq = 2*pi*(1/ts)*linspace(0,1,NFFT+1);
        last_in = (NFFT+1)/2;
        freq = freq(1:last_in);
    else
        freq = pi*(1/ts)*linspace(0,1,NFFT/2+1);
    end
    % Preallocate response
    resp = zeros(numoutch,numin,numel(freq));
    % Input is common compute FFT
    infft = fft(insig.Data,NFFT);
    for ctin = 1:numin
        cur_out_ind = 1;
        for ctout = 1:numoutio
            % Find number of channels in this IO 
            numtimesteps = numel(simout{ctin}(ctout).Output.Time(:));
            out = LocalGetData(simout{ctin}(ctout).Output.Data,numtimesteps);
            tsoutio = simout{ctin}(ctout).OutputSignalTs;
            tsinio = simout{ctin}(ctout).InputSignalTs;
            numchthisio = prod(simout{ctin}(ctout).Output.SignalDimensions);
            for ctch = 1:numchthisio
                outfft = fft(out(:,ctch),NFFT);
                Txy = outfft(:)./infft(:);
                respthisch = Txy(1:numel(freq));
                % If original source of input and output signal is of
                % continuous, take ZOH effect into account except DC term.
                if isequal(tsoutio(1),0) && isequal(tsinio(1),0)
                    zohthisch = (1-exp(-1i*freq(2:end)*ts))./(1i*freq(2:end)*ts);
                    respthisch(2:end) = respthisch(2:end)./zohthisch(:);
                end
                resp(cur_out_ind,ctin,:) = respthisch;                
                cur_out_ind = cur_out_ind + 1;
            end
        end
    end
    % For chirp, eliminate those frequencies out of the range
    if isa(in,'frest.Chirp')
        indfreq = freq>=unitconv(min(in.FreqRange),in.FreqUnits,'rad/s') & freq<=unitconv(max(in.FreqRange),in.FreqUnits,'rad/s');
        freq = freq(indfreq);
        resp = resp(:,:,indfreq);
    end
    sysest = frd(resp,freq);                                    
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFRDNames
%  Creates the names to populate InputName & OutputName fields of the FRD
%  result
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outputnames inputnames] = LocalFRDNames(simout,table)
numin = numel(simout);
numoutch = LocalFindTotalNumberOfOutputChannels(simout);
numoutio = numel(simout{1});
% Initialize names
outputnames = cell(numoutch,1);
inputnames = cell(numin,1);
% Populate outputnames using Name field in Simulink.Timeseries
output_ind = 1;
for ctout = 1:numoutio
    % Find number of channels in this IO
    dims = simout{1}(ctout).Output.SignalDimensions;
    numchthisio = prod(dims);
    str = simout{1}(ctout).Output.Name;
    if numchthisio == 1
        % Scalar output
        outputnames{output_ind} = str;
        output_ind = output_ind + 1;
    else
        % Non-scalar output
        numdims = numel(dims);
        for ctch = 1:numchthisio
            % Construct index info in parentheses for each channel
            if (numdims == 1) || (dims(1) == 1)
                % 1-D array or Row Vector
                outputnames{output_ind} = sprintf('%s (%d)',str,ctch);
                output_ind = output_ind + 1;
            else
                % Matrix or n-D
                ind = cell(1,numdims);
                [ind{1:numdims}] = ind2sub(dims,ctch);
                strind = sprintf('(%d',ind{1});
                for ctd = 2:numel(ind)
                    strind = sprintf('%s,%d',strind,ind{ctd});
                end
                strind = sprintf('%s)',strind);
                outputnames{output_ind} = sprintf('%s %s',str,strind);
                output_ind = output_ind + 1;
            end
        end
    end    
end
% Populate inputnames
% Find input IOs
ind = find(strcmp(table(:,3),'Input') | strcmp(table(:,3),'Both'));
input_ind = 1;
for ctio = ind'
    % Get dimensions of this input IO
    dims = table{ctio,4}.Dimensions;
    str = table{ctio,6};
    if prod(dims) == 1 || prod(dims(2:end)) == 1
        % Scalar input
        inputnames{input_ind} = str;
        input_ind = input_ind + 1;
    else
        numchannels = prod(dims(2:end));         
        if (dims(1) == 1) || ((dims(1) == 2) && (dims(2) == 1))
            % Vector or Row Vector(1nx)
            for ctch = 1:numchannels
                inputnames{input_ind} = sprintf('%s (%d)',str,ctch);
                input_ind = input_ind + 1;
            end
        else
            % Matrix or n-D
            numdims = dims(1);
            dims = dims(2:end);
            for ctch = 1:numchannels
                ind = cell(1,numdims);
                [ind{1:numdims}] = ind2sub(dims,ctch);
                strind = sprintf('(%d',ind{1});
                for ctd = 2:numel(ind)
                    strind = sprintf('%s,%d',strind,ind{ctd});
                end
                strind = sprintf('%s)',strind);
                inputnames{input_ind} = sprintf('%s %s',str,strind);
                input_ind = input_ind + 1;
            end
        end
    end
end

end
function [outputnames inputnames] = LocalFRDNamesFromResponse(resp,table)
numin = size(resp,2);
numoutch = size(resp,1);
ind = find(strcmp(table(:,3),'Output') | strcmp(table(:,3),'Both'));
numoutio = numel(ind);
% Initialize names
outputnames = cell(numoutch,1);
inputnames = cell(numin,1);
% Populate outputnames using Name field in Simulink.Timeseries
output_ind = 1;
for ctout = 1:numoutio
    % Find number of channels in this IO
    dims = table{ind(ctout),4}.Dimensions;
    if isscalar(dims)
        numchthisio = dims;
    else
        numchthisio = prod(dims(2:end));
    end
    str = table{ind(ctout),6};
    if numchthisio == 1
        % Scalar output
        outputnames{output_ind} = str;
        output_ind = output_ind + 1;
    else
        % Non-scalar output
        dims = dims(2:end);
        numdims = numel(dims);
        for ctch = 1:numchthisio
            % Construct index info in parentheses for each channel
            if numdims == 1
                % Vector
                outputnames{output_ind} = sprintf('%s (%d)',str,ctch);
                output_ind = output_ind + 1;
            else
                % Matrix or n-D
                ind = cell(1,numdims);
                [ind{1:numdims}] = ind2sub(dims,ctch);
                strind = sprintf('(%d',ind{1});
                for ctd = 2:numel(ind)
                    strind = sprintf('%s,%d',strind,ind{ctd});
                end
                strind = sprintf('%s)',strind);
                outputnames{output_ind} = sprintf('%s %s',str,strind);
                output_ind = output_ind + 1;
            end
        end
    end    
end
% Populate inputnames
% Find input IOs
ind = find(strcmp(table(:,3),'Input') | strcmp(table(:,3),'Both'));
input_ind = 1;
for ctio = ind'
    % Get dimensions of this input IO
    dims = table{ctio,4}.Dimensions;
    str = table{ctio,6};
    if prod(dims) == 1 || prod(dims(2:end)) == 1
        % Scalar input
        inputnames{input_ind} = str;
        input_ind = input_ind + 1;
    else
        numchannels = prod(dims(2:end));         
        if dims(1) == 1 || ((dims(1) == 2) && (dims(2) == 1))
            % Vector or Row Vector
            for ctch = 1:numchannels
                inputnames{input_ind} = sprintf('%s (%d)',str,ctch);
                input_ind = input_ind + 1;
            end
        else
            % Matrix or n-D
            numdims = dims(1);
            dims = dims(2:end);
            for ctch = 1:numchannels
                ind = cell(1,numdims);
                [ind{1:numdims}] = ind2sub(dims,ctch);
                strind = sprintf('(%d',ind{1});
                for ctd = 2:numel(ind)
                    strind = sprintf('%s,%d',strind,ind{ctd});
                end
                strind = sprintf('%s)',strind);
                inputnames{input_ind} = sprintf('%s %s',str,strind);
                input_ind = input_ind + 1;
            end
        end
    end
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFRDSampleTime
%  Computes the sample time field of the FRD results based on sample times
%  of Simulink signals at input and output points
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ts = LocalFRDSampleTime(iotable)
% Gather all sample times
numio = size(iotable,1);
tsset = [];
for ct = 1:numio
    % Ignore pure loop openings since they do not matter
    if ~strcmp(iotable{ct,3},'None')
        tsset(end+1,:) = iotable{ct,4}.SampleTime; %#ok<AGROW>
    end
end
if all(tsset(:,1)==0)
    % Purely continuous signals
    ts = 0;
else
    % Check first if continuous mixture
    uniqts = unique(tsset(:,1));
    if numel(uniqts) ~= 1
        % Continuous-discrete mixture, set to (slowest) discrete
        % rate        
        ts = uniqts(end);
        % Find continuous and discrete I/O indices to report
        cont_io_ind = []; disc_io_ind = [];
        for ct = 1:numio
            if ~strcmp(iotable{ct,3},'None')
                if iotable{ct,4}.SampleTime(1) == 0
                    cont_io_ind(end+1) = ct; %#ok<AGROW>
                else
                    disc_io_ind(end+1) = ct; %#ok<AGROW>
                end
            end
        end
        % Throw a warning
        ctrlMsgUtils.warning('Slcontrol:frest:ContDiscTsMixture',...
                             mat2str(cont_io_ind),...
                             mat2str(disc_io_ind),sprintf('%g',ts),sprintf('%g',ts));
    else
        % Pure discrete case
        ts = uniqts;        
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFindTotalNumberOfOutputChannels
%  Finds the total number of output channel to appear in the FRD result.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function numoutch = LocalFindTotalNumberOfOutputChannels(simout)
numoutch = 0;
for ctout = 1:numel(simout{1})
    numoutch = numoutch+prod(simout{1}(ctout).Output.SignalDimensions);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalReadSimulationMaterialInWorker
%  Read the simulation data from model workspace of the model opened in the
%  worker machine
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [parammgr,simulationPackage,rpt,varargout] = LocalReadSimulationMaterialInWorker(mdl,names)
hws = get_param(mdl,'ModelWorkspace');
modelVars = evalin(hws,'who');
numout = nargout;
if numout > 3
    outnames = cell(1,3);
end
% Look for parameter manager among first variables
for ctw = 1:numel(names)
    if any(strcmp(names{ctw}{1},modelVars))
        parammgr = evalin(hws,names{ctw}{1});
        if numout > 3
            outnames{1} = names{ctw}{1};
        end            
        break;
    end        
end
% Look for simulation package among second variables
for ctw = 1:numel(names)
    if any(strcmp(names{ctw}{2},modelVars))
        simulationPackage = evalin(hws,names{ctw}{2});
        if numout > 3
            outnames{2} = names{ctw}{2};
        end
        break;
    end
end
% Look for rapid target among third variables
for ctw = 1:numel(names)
    if any(strcmp(names{ctw}{3},modelVars))
        rpt = evalin(hws,names{ctw}{3});
        if numout > 3
            outnames{3} = names{ctw}{3};
        end
        break;
    end        
end

if numout > 3
    varargout{1} = outnames;
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalWriteSimulationMaterialInWorker
%  Write the simulation data to model workspace of the model that is opened
%  in the worker machine
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function names = LocalWriteSimulationMaterialInWorker(parammgr,simulationPackage,rpt,varargin)
if nargin > 3
    names = varargin{:};
else
    names = findVariableNames(parammgr,...
        {'Worker_ModelParameterMgr',...
        'Worker_SimulationPackage',...
        'Worker_RapidAccelTarget'});
end

% Write them to model workspace
hws = get_param(parammgr.Model,'ModelWorkspace');
assignin(hws,names{1},parammgr);
assignin(hws,names{2},simulationPackage);
assignin(hws,names{3},rpt);

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalClearSimulationMaterialInWorker
%  Clear the simulation data from model workspace of the model that is
%  opened in the worker machine
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalClearSimulationMaterialInWorker(mdl,names)
hws = get_param(mdl,'ModelWorkspace');
modelVars = evalin(hws,'who');
% Find and clean parameter manager among first variables
for ctw = 1:numel(names)
    if any(strcmp(names{ctw}{1},modelVars))
        cmd = sprintf('clear %s',names{ctw}{1});
        evalin(hws,cmd);
        break;
    end        
end

% Find and clean simulation package among second variables
for ctw = 1:numel(names)
    if any(strcmp(names{ctw}{2},modelVars))
        cmd = sprintf('clear %s',names{ctw}{2});
        evalin(hws,cmd);
        break;
    end        
end

% Find and clean rapid target among third variables
for ctw = 1:numel(names)
    if any(strcmp(names{ctw}{3},modelVars))
        cmd = sprintf('clear %s',names{ctw}{3});
        evalin(hws,cmd);
        break;
    end        
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalHasAnyErrorOccurredOnWorkers
%  Inspect error flags returned by simulations in workers and find out if
%  any error has occurred and return the exception if error has occurred.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errorsOccurred,except] = LocalHasAnyErrorOccurredOnWorkers(errWorkers)
except = [];
errorsOccurred = false;
for ct = numel(errWorkers):-1:1
    if iscell(errWorkers{ct})
        noErrorsOccurred(ct) = all(cellfun(@isempty,errWorkers{ct}));
        if ~noErrorsOccurred(ct)            
            % Get into cell array to extract exception
            for ctc = 1:numel(errWorkers{ct})
                if ~isempty(errWorkers{ct}{ctc})
                    except = errWorkers{ct}{ctc}.Exception;
                    break;
                end
            end
            errorsOccurred = true;
            break;            
        end
    else
        noErrorsOccurred(ct) = isempty(errWorkers{ct});
        if ~noErrorsOccurred(ct)
            except = errWorkers{ct}.Exception;
            errorsOccurred = true;
            break;
        end
    end
end    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalRestoreWorkers
%  Restore the worker machines: Restore open models, clean up variables and
%  restore path settings.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRestoreWorkers(mdl,workerVarNames,nWorkers)
% Restore the model and clean up variables created in the model
% workspace for each worker
parfor ct = 1:nWorkers
    [parammgrw,SimulationPackageW,~] = LocalReadSimulationMaterialInWorker(mdl,workerVarNames);
    LocalClearSimulationMaterialInWorker(mdl,workerVarNames);
    LocalRestoreModel(parammgrw,SimulationPackageW);    
end
% Restore the state of workers
parallelsim.cleanupWorkers;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalBuildForRapidSimOverFrequenciesOnEachWorker
%  Build the rapid simulation target on each worker
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err = LocalBuildForRapidSimOverFrequenciesOnEachWorker(mdl,names,ctexp)
err = [];
% Read the setup material
[parammgr_prepw,SimulationPackagePrepW,~,namesreadfrom] = LocalReadSimulationMaterialInWorker(mdl,names);
injdata = SimulationPackagePrepW.InjectionDataArray(ctexp).InjectionData;
try
    % Build the rapid target
    rtpw = LocalBuildForRapidSimOverFrequencies(parammgr_prepw,SimulationPackagePrepW,injdata);
catch Me
    err = Me;
    return;
end
% Write the build rapid target material back to the workspace with same
% names
LocalWriteSimulationMaterialInWorker(parammgr_prepw,SimulationPackagePrepW,rtpw,namesreadfrom);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalBuildForRapidSimOverFrequencies
%  Build the rapid simulation target for OneAtATime Sinestream with
%  constant sample time over frequencies
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rtp = LocalBuildForRapidSimOverFrequencies(ModelParameterMgr,SimulationPackage,injdata)
if SimulationPackage.IsRapidSimWithConstantTsOverFreq
    % build
    ModelParameterMgr.distributeInjectionData(injdata);
    rtp = Simulink.BlockDiagram.buildRapidAcceleratorTarget(ModelParameterMgr.Model);
else
    rtp = [];
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalDistributeFrequenciesAcrossWorkers
%  Specify the distribution of frequencies across workers
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function workerBuckets = LocalDistributeFrequenciesAcrossWorkers(numfreq,nWorkers)
workerBuckets = cell(1,nWorkers);
freq = 1:numfreq;
numChunks = floor(numfreq/nWorkers);
% Place the frequencies in workers fairly
for ctc = 1:numChunks
   for ctw = 1:nWorkers
       freqoffset = (ctc-1)*nWorkers;
       if rem(ctc,2) == 0
           workerBuckets{ctw}(end+1) = freq(freqoffset+ctw);
       else
           workerBuckets{ctw}(end+1) = freq(freqoffset+nWorkers+1-ctw);
       end
   end
end

% Place the rest of frequencies
loop_index = 1;
for ct = (numChunks*nWorkers)+1:numfreq
    workerBuckets{loop_index}(end+1) = freq(ct);
    loop_index = loop_index + 1;    
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalPackResponseFromWorkers
%  Repackage the responses coming from individual workers for various
%  experiment into FRD response from.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resp = LocalPackResponseFromWorkers(workerBuckets,respFromWorkers,numfreq)
numexp = numel(respFromWorkers);
numoutputch = max(cellfun(@numel,respFromWorkers{1}{1}));
nWorkers = numel(workerBuckets);
resp = zeros(numoutputch,numexp,numfreq);
for cte = 1:numexp
    for ctf = 1:numfreq
        for ctch = 1:numoutputch
            worker_index = [];
            for ctw = 1:nWorkers
                if ~isempty(find(workerBuckets{ctw} == ctf, 1))
                    worker_index = ctw;
                    break;
                end
            end
            resp(ctch,cte,ctf) = respFromWorkers{cte}{worker_index}{ctf}(ctch);
        end
    end
end
end




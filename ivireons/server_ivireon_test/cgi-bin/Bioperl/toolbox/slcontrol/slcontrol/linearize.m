function [sys,varargout] = linearize(model,varargin)
% LINEARIZE Obtains a linear model from a Simulink model.
%
%   LIN = LINEARIZE('sys',IO) takes a Simulink model name, 'sys' and an I/O
%   object, IO, as inputs and returns a linear time-invariant state-space
%   model, LIN. The linearization I/O object is created with the function
%   GETLINIO or LINIO. IO must be associated with the same Simulink model,
%   sys.
%
%   LIN = LINEARIZE('sys',OP,IO) takes a Simulink model name, 'sys', an
%   operating point object, OP, and an I/O object, IO, as inputs and
%   returns a linear time-invariant state-space model, LIN. The operating
%   point object is created with the function OPERPOINT or FINDOP. The
%   linearization I/O object is created with the function GETLINIO or
%   LINIO. Both OP and IO must be associated with the same Simulink model,
%   sys.
%
%   LIN = LINEARIZE('sys',OP,IO,OPTIONS) linearizes the Simulink model 'sys'
%   using the options object, OPTIONS. The linearization options object
%   is created with the function LINOPTIONS and contains several options
%   for linearization.
%
%   LIN_BLOCK = LINEARIZE('sys',OP,'blockname') returns a linearization of
%   a Simulink block named 'blockname' in the model 'sys'. You can also
%   supply a fourth argument, OPTIONS, to provide options for the
%   linearization. Create options with the function LINOPTIONS.
%
%   LIN = LINEARIZE('sys',OP) creates a linearized model, LIN, using the
%   root-level inport and outport blocks in sys.  You can also supply a
%   third argument, OPTIONS, to provide options for the linearization.
%   Create options with the function LINOPTIONS.
%
%   LIN = LINEARIZE('sys',OP,OPTIONS) is the form of the linearize function
%   that is used with numerical-perturbation linearization. The function
%   returns a linear time-invariant state-space model, LIN, of the entire
%   model, 'sys'.  The LinearizationAlgorithm option must be set to
%   'numericalpert' within OPTIONS for numerical-perturbation linearization
%   to be used. Create the variable options with the linoptions function.
%   The function uses the root-level inport and outport blocks in the model
%   as inputs and outputs for linearization.
%
%   [LIN,OP] = LINEARIZE('sys',SNAPSHOTTIMES); creates operating points for
%   the linearization by simulating the model, 'sys', and taking snapshots
%   of the system's states and inputs at the times given in the vector
%   snapshottimes. The function returns LIN, a set of linear time-invariant
%   state-space models evaluated and OP, the set of operating point objects
%   used in the linearization. You can specify input and output points for
%   linearization by providing an additional argument such as a linearization
%   I/O object created with GETLINIO or LINIO, or a block name. If an I/O
%   object or block name is not supplied the linearization will use root-level
%   inport and outport blocks in the model. You can also supply a
%   fourth argument, OPTIONS, to provide options for the linearization.
%   Create options with the function LINOPTIONS.
%
%   LIN = LINEARIZE('sys',BLOCKSUBS,IO) takes a Simulink model named 'sys',
%   a nx1 structure BLOCKSUBS specifying blocks in a Simulink model with a
%   desired linearization, and an I/O object, IO, and returns a linear
%   state-space model, LIN.  The structure BLOCKSUBS contains two fields:
%   'Block' a string specifying the Simulink block to replace 'Value' a
%   structure that specifies the block linearization the structure contains
%   the following fields:
%   Specification: Either the MATLAB expression or function to specify the  
%                  linearization (STRING)
%        	 Type: Describes the type of specification.  This parameter 
%                  should either be 'Expression' or 'Function'.
%  ParameterNames: A comma separated list containing the name of parameters
%                  which will be evaluated in the scope of the block.  The
%                  evaluated values will be available inside the function.
%                  This field is ignored and is not required in the case 
%                  when the specification is a MATLAB expression.
% ParameterValues: A comma separated list containing parameters which will 
%                  be evaluated in the scope of the block.  
% 
%   LIN = LINEARIZE('sys',BLOCKSUBS,IO) takes a Simulink model named 'sys', 
%   a nx1 structure BLOCKSUBS, and an I/O object, IO, as inputs and returns 
%   a linear state-space model, LIN.
% 
%   LIN = LINEARIZE('sys',BLOCKSUBS,IO,OP) takes a Simulink model named
%   'sys', a nx1 structure BLOCKSUBS, an I/O object, IO, and operating
%   point OP, as inputs and returns a linear state-space model, LIN.  The
%   operating point OP can be an operating point created using the function
%   OPERPOINT or FINDOP.  In addition OP can be a vector of simulation
%   times that LIN is computed during a simulation.
%
%   LIN = LINEARIZE('sys','StateOrder',STATEORDER) takes a Simulink model
%   name, 'sys' and returns a linear time-invariant state-space model, LIN.
%   The order of the states in LIN are specified in a cell array STATEORDER
%   containing the names of the blocks (full block path or state name) with
%   states in the Simulink model, 'sys'.
%
%   See also LINIO, GETLINIO, OPERPOINT, FINDOP.

%  Author(s): John Glass
%  Revised:
%   Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.59.2.1 $ $Date: 2010/07/26 15:40:16 $

% Get instance of a model parameter manager for this model
ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(model);
ModelParameterMgr.loadModels;

% Determine if the model is stopped.  This will be used to determine
% whether or not we need to recompile the model.
isrunning = strcmp(get_param(model,'SimulationStatus'),'running');

% Parse the input arguments
snapshottimes = [];
LinData = struct('op',[],'io',[],'iospec',[],'block',[],'StoreJacobianData',false,...
            'opt',[],'StateOrder',[],'FoldFactors',true,...
            'ReturnOperatingPoint',nargout>1,...
            'BlockSubs',struct('Name',cell(0,1),'Value',zeros(0,1)));
for ct = 1:nargin-1
    var = varargin{ct};
    if isempty(var)
        ctrlMsgUtils.error('Slcontrol:linearize:EmptyLinearizationIO')
    elseif isa(var,'LinearizationObjects.linoptions')
        LinData.opt = var;
    elseif isa(var,'linearize.IOPoint')
        io  = var;
        % Test to be sure that the linearization IOs have unique block/port
        % combinations
        ActiveInd = strcmp(get(io,{'Active'}),'on');
        io = io(ActiveInd);
        LinData.io = io;
        if ~isIOsUnique(io)
            ctrlMsgUtils.error('Slcontrol:linearize:UniqueIOBlockPortPairNeeded')
        end
        % Set the I/O spec to pass to jacobian engine
        LinData.iospec = linearize.createIOSpecStructure(io);
    elseif (isa(var,'char') && strcmp(var, 'StateOrder'));
        LinData.StateOrder = varargin{ct + 1};
    elseif (isa(var,'char') && strcmp(var, 'StoreJacobianData'))
        LinData.StoreJacobianData = varargin{ct+1};
    elseif  (isa(var,'char') && strcmp(var, 'FoldFactors'))
        LinData.FoldFactors = varargin{ct+1};
    elseif (isa(var,'char') || isa(var,'Simulink.Block'))
        % Get the UDD block handle
        if isa(var,'Simulink.Block')
            LinData.block = var;
        else
            LinData.block = get_param(var,'Object');
        end
    elseif isa(var, 'struct') && isfield(var,'Value')
        % Verify that the blocks being substituted are valid
        LinData.BlockSubs = var;
        for dt = 1:numel(var)
            try
                find_system(var(dt).Name);
            catch Ex
                ctrlMsgUtils.error('Slcontrol:linearize:BlockSubDoesNotExist',var(dt).Name);
            end
        end        
    elseif isa(var, 'double')
        snapshottimes = var;
    elseif isa(var, 'opcond.OperatingPoint')
        op = var;
        
        % Check to see if the model matches the operating point
        for ct2 = 1:numel(op)
            if ~(strcmp(model,op(ct2).Model))
                ctrlMsgUtils.error('Slcontrol:linearize:ModelDoesNotMatchOperatingPoint')
            end
        end
        LinData.op = op;
    end
end

% Create an options object if one was not specified
if isempty(LinData.opt)
    LinData.opt = linoptions;
else
    LinData.opt = copy(LinData.opt);
end
% Compute the desired sample time
LinData.opt.SampleTime = LocalComputeSampleTime(LinData.opt);

if strcmp(LinData.opt.LinearizationAlgorithm,'numericalpert')
    if ~isempty(LinData.block)
        ctrlMsgUtils.error('Slcontrol:linearize:PerturbationNotValidBlockLinearization')
    elseif ~isempty(LinData.io)
        ctrlMsgUtils.error('Slcontrol:linearize:PerturbationNotValidPortIOLinearization')
    elseif ~isempty(snapshottimes)
        ctrlMsgUtils.error('Slcontrol:linearize:PerturbationNotValidSimulationLinearization')
    elseif ~isempty(LinData.BlockSubs)
        ctrlMsgUtils.error('Slcontrol:linearize:PerturbationNotValidBlockReplacement')
    end
    [sys,J,iostruct] = LocalNumericalPertLinearization(ModelParameterMgr,LinData);
    if nargout > 1
        varargout{1} = J;
        varargout{2} = iostruct;
    end
else    
    % Set up the linearization IOs
    if ~isempty(LinData.block)
        % Get the UDD block handle
        if ~isa(LinData.block,'Simulink.Block')
            LinData.block = get_param(LinData.block,'Object');
        end
        % Compute the io for the block linearization
        LinData.io = linearize.getBlockIOPoints(LinData.block);
        % Set the I/O spec to pass to jacobian engine
        LinData.iospec = linearize.createIOSpecStructure(LinData.io);
        IOStructArgs = {'block',LinData.block};
    elseif ~isempty(LinData.io)
        IOStructArgs = {'iopoints'};
    else
        IOStructArgs = {'rootports'};    
    end
    iostructfcn = @(J)utGetIOStruct(ModelParameterMgr,J,LinData.opt,...
        LinData.io,IOStructArgs{:});
       
    % Linearize the model
    if ~isempty(snapshottimes)
        % Get the snapshot times and create the snapshot object
        evt = LinearizationObjects.LinearizationSnapShotEvent(...
            ModelParameterMgr,LinData,snapshottimes,iostructfcn);
       
        % Run the snapshot
        try
           Data = evt.runsnapshot;
        catch E
           %Close any models that were opened
           ModelParameterMgr.closeModels;
           rethrow(E)
        end
        
        % Create the lti array for the linearization
        if ~isempty(Data)
            FirstStateName = Data(1).sys.StateName;
            isuss = isa(Data(1).sys,'uss');
            try
               LocalCheckUniformSampleTime(Data);
            catch E
               %Close any models that were opened
               ModelParameterMgr.closeModels;
               rethrow(E)
            end
            for ct = numel(Data):-1:1
                if isuss && ~isequal(FirstStateName,Data(ct).sys.StateName)
                    ctrlMsgUtils.error('Slcontrol:linearize:ErrorUSSStateNamesCannotVary')
                end                
                sys(:,:,ct) = Data(ct).sys;
                SysNotes{ct} = Data(ct).sys.Notes{:};
            end            
            set(sys,'Notes',SysNotes);
            
            varargout{1} = [Data.OperatingPoint];
            if LinData.StoreJacobianData
                InspectorData = [Data.InspectorData];
                for ct = 1:numel(InspectorData)
                    BlocksInPathByName{ct} = Data(ct).InspectorData.BlocksInPathByName;
                    DiagnosticMessages{ct} = Data(ct).InspectorData.DiagnosticMessages;
                end
                varargout{2} = struct('TopTreeNode',InspectorData(1).TopTreeNode,...
                    'DiagnosticMessages',{DiagnosticMessages},...
                    'BlocksInPathByName',{BlocksInPathByName},...
                    'J',[InspectorData.J]);
            else
                varargout{2} = [];
            end
            varargout{3} = [Data.iostruct];
        else
            sys = [];
            varargout = cell(1,3);
        end
        
        %Close any models that were opened
        ModelParameterMgr.closeModels;
    else
        if ~isrunning
            % Check for a single tasking solver
            checkSingleTaskingSolver(linutil,model);
        end
        
        % Compute the linearization
        [sys,InspectorData,iostruct] = LocalLinearizeModel(ModelParameterMgr,LinData,iostructfcn);
        
        if nargout > 1
            if LinData.StoreJacobianData
                varargout{1} = InspectorData;
            else
                varargout{1} = [];
            end
            varargout{2} = iostruct;
        end
    end
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalLinearizeModel
%  Obtains linear models from systems of ODEs and discrete-time systems.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,InspectorData,iostruct] = LocalLinearizeModel(ModelParameterMgr,LinData,iostructfcn)

io = LinData.io;
op = LinData.op;
opt = LinData.opt;

% Determine if the model is stopped.  This will be used to determine
% whether or not we need to recompile the model.
model = ModelParameterMgr.Model;
models = getUniqueNormalModeModels(ModelParameterMgr);
simstat = get_param(model,'SimulationStatus');
isrunning = strcmp(simstat,'running') || strcmp(simstat,'paused');

% Get the linearization times
if isempty(op)
    t = 0;
else
    t = get(op,{'Time'}); t = [t{:}];
end
curr_time = t(end);
unique_linearization_time = (numel(unique(t)) == 1);

if isempty(op) && strcmp(get_param(model,'LoadInitialState'),'on')
   op = opcond.OperatingPoint(model);
   op.update;
end

% Get the state order from a single operating point if it has not been
% specified.
if (numel(op) == 1) && isempty(LinData.StateOrder)
    LinData.StateOrder = getNonAccelReferenceStateBlockNames(op);
end

% Parameter settings we need to set/cache before linearizing
if ~isrunning
    % Determine if there is a non-double inport.  This will be the case
    % when the number of root level input ports is not equal to the number
    % of input point objects.
    if ~isempty(op) && numel(op(1).Inputs)
        useModelu = false;
    else
        useModelu = true;
    end
    
    % Load model, save old settings, install new ones suitable for
    % linearization
    if isempty(op)
        useModelx0 = true;
    else
        useModelx0 = false;
    end
    [ConfigSetParameters,ModelParams] = createLinearizationParams(linutil,useModelx0,useModelu,io,curr_time,LinData.opt);
    ModelParams.SimulationMode = 'normal';
    
    % Tell the model which blocks to remove
    if ~isempty(LinData.BlockSubs)
        BlocksToRemove = {LinData.BlockSubs.Name};
        ModelParams.SCDLinearizationBlocksToRemove = BlocksToRemove(:);
    end
       
    try
        ModelParameterMgr.LinearizationIO = io;
        ModelParameterMgr.ModelParameters = ModelParams;
        ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
        ModelParameterMgr.prepareModels('linearization');
    catch Ex
        % Restore the model settings
        ModelParameterMgr.restoreModels;
        ModelParameterMgr.closeModels;
        if strcmp(Ex.identifier,'Simulink:Libraries:RefViolation')
            if ~isempty(LinData.BlockSubs)
                ctrlMsgUtils.error('Slcontrol:linearize:BlockSubLibraryLinks')                
            else
                ctrlMsgUtils.error('Slcontrol:linearize:LinearizationIOLibraryLinks')                
            end
        else
            rethrow(Ex)
        end
    end
end

% Don't let sparse math re-order columns
autommd_orig = spparms('autommd');
spparms('autommd', 0);
ismodelcompiled = false;

if ~isrunning
    try
        ModelParameterMgr.compile('lincompile');
        ismodelcompiled = true;
        if isempty(op) && LinData.ReturnOperatingPoint
            op = opcond.OperatingPoint(model);
            sync(op,false);
        end
    catch LinearizeCompilationException
        LocalModelCleanUp(ModelParameterMgr, ismodelcompiled,autommd_orig)
        if strcmp(LinearizeCompilationException.identifier,'Simulink:Bus:SigHierPropSrcDstMismatchBusSrc')
            ctrlMsgUtils.error('Slcontrol:linearize:ErrorCompilingModelforBusLabeling',model,model);
        else
            throwAsCaller(LinearizeCompilationException)
        end
    end
end

% Perform the linearization
try
    if ~isempty(op)
        for ct = numel(op):-1:1
            if ~isrunning
                % Compile the model
                if ~unique_linearization_time && (curr_time ~= op(ct).Time)
                    % Set the new current time.
                    curr_time = op(ct).Time;
                    % If the linearization times are different then the current
                    % set then terminate compilation.  This is needed for blocks
                    % like the step block that do not change level by pushing the
                    % time variable through the model api.
                    ModelParameterMgr.term;
                    ismodelcompiled = false;
                    startTimeStr = sprintf('%.17g',op(ct).Time);
                    stopTimeStr = sprintf('%.17g',op(ct).Time+1);
                    for ct2 = 1:numel(models)
                        set_param(models{ct2},'StartTime', startTimeStr,...
                            'StopTime',  stopTimeStr);
                    end
                    ModelParameterMgr.compile('lincompile');
                    ismodelcompiled = true;
                end
                
                % Push the operating point onto the model
                utPushOperatingPoint(linutil,model,op(ct),opt);
            end
            
            % Get the Jacobian data structure
            J_iter = getJacobian(linutil,model,LinData.iospec);
            % Evalute the Jacobian
            [sys{ct},userdef_stateName,iostruct(ct),J(ct)] = ...
                utProcessJacobian(linutil,ModelParameterMgr,J_iter,LinData,iostructfcn);
        end
        % Convert from cell to LTI-array if unique sample time, error
        % otherwise
        LocalCheckUniformSampleTime(sys);        
        sys = stack(1,sys{:});
        
    else
        % Get the Jacobian data structure
        J_iter = getJacobian(linutil,model,LinData.iospec);
        % Evalute the Jacobian
        [sys,userdef_stateName,iostruct,J] = ...
            utProcessJacobian(linutil,ModelParameterMgr,J_iter,LinData,iostructfcn);
    end
    % Reorder the states to match the order specified
    [sys, iostruct] = utOrderNameStates(linutil,model,sys,J,userdef_stateName,iostruct,LinData);
catch LinearizeComputationException
    if ~isrunning
        % Restore the model settings
        LocalModelCleanUp(ModelParameterMgr, ismodelcompiled, autommd_orig)
    end
    rethrow(LinearizeComputationException)
end
        
if LinData.StoreJacobianData
    TopTreeNode = linearize.getInspectorData(ModelParameterMgr,model,J);
    [DiagnosticMessages,BlocksInPathByName] = linearize.getDiagnosticData(J);
    InspectorData = struct('TopTreeNode',TopTreeNode,...
                        'DiagnosticMessages',{DiagnosticMessages},...
                        'BlocksInPathByName',{BlocksInPathByName},...
                        'J',J);
else
    InspectorData = [];
end
        
if ~isrunning
    LocalModelCleanUp(ModelParameterMgr, ismodelcompiled, autommd_orig);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalModelCleanUp(ModelParameterMgr, ismodelcompiled, varargin)
% Terminate the compilation
if ismodelcompiled
    ModelParameterMgr.term;
end

% Restore the previous sparse math settings
if nargin > 2
    autommd_orig = varargin{1};
    spparms('autommd', autommd_orig);
end

% Restore the model settings
ModelParameterMgr.restoreModels;
ModelParameterMgr.closeModels;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalNumericalPertLinearization
%  Computes the linearization using the standard root level linearization
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,J,iostruct] = LocalNumericalPertLinearization(ModelParameterMgr,LinData)

op = LinData.op;
opt = LinData.opt;

% Parameter settings we need to set/cache before linearizing
model = ModelParameterMgr.Model;
want = struct('SimulationMode', 'normal',...
    'LoadInitialState','off',...
    'LoadExternalInput','off',...
    'RTWInlineParameters', 'on');
ModelParameterMgr.ModelParameters = want;
ModelParameterMgr.prepareModels('linearization');

% If the LoadInitialState flag is on use the operpoint command to get the
% operating point since the integrators will not try to overwrite their
% initial conditions.
if isempty(op) && strcmp(get_param(model,'LoadInitialState'),'on')
   op = opcond.OperatingPoint(model);
   op.update;
end

% Get the model sample times and state names
[~,~,~,~,Ts] = ModelParameterMgr.compile('lincompile');
ismodelcompiled = true;

% Check if the model has any inport/outport with non-double data
if hasNonDoubleInportOutport(linutil,ModelParameterMgr.Model);
    LocalModelCleanUp(ModelParameterMgr, ismodelcompiled);
    ctrlMsgUtils.error('Slcontrol:linearize:PerturbationNotValidInportOutport');
end

% Validate the operating point
try
    op = LocalValidateOperatingPoints(model,op,opt,false);
catch Ex
    % Clean up
    LocalModelCleanUp(ModelParameterMgr, ismodelcompiled)
    rethrow(Ex);
end

% Get the user defined sample rate
ts = LocalComputeSampleTime(opt);

if ts == -1
    % The first column of Tsx are the sample times
    Tsx = Ts(:,1);
    % Remove the infinite sample times
    Tsx(isinf(Tsx)) = 0;
    % Compute the slowest sample time
    ts = max(Tsx(:));
    if isempty(Tsx)
        ts = 0;
    end
end

% Find the port names
truncatename = strcmp(opt.UseFullBlockNameLabels,'off');
% Obtain the inports and outports
% Inports
blocks = find_system(model,'SearchDepth',1,'BlockType','Inport');
inports = [];
ph = get_param(blocks,'PortHandles');
for ct = 1:length(blocks)
    dims = get_param(ph{ct}.Outport,'CompiledPortDimensions');
    inports = [inports;repmat(ph{ct}.Outport,prod(dims(2:end)),1)];
end
% Outports
blocks = find_system(model,'SearchDepth',1,'BlockType','Outport');
outports = [];
ph = get_param(blocks,'PortHandles');
for ct = 1:length(blocks)
    dims = get_param(ph{ct}.Inport,'CompiledPortDimensions');
    outports = [outports;repmat(ph{ct}.Inport,prod(dims(2:end)),1)];
end

inname = get_param(inports,'Parent');
outname = get_param(outports,'Parent');
iostruct = getioindices(linutil,ModelParameterMgr,[],inports,outports,inname,outname,'rootports',truncatename,...
    strcmp(opt.UseBusSignalLabels,'on'));

% Get the user defined perturbation options
try
    relpert = LocalEvalParam(opt.NumericalPertRel);
    xpert_param = LocalEvalParam(opt.NumericalXPert);
    upert_param = LocalEvalParam(opt.NumericalUPert);
catch ParamEvalException
    % Clean up
    LocalModelCleanUp(ModelParameterMgr, ismodelcompiled)
    throwAsCaller(ParamEvalException)
end

for ct = 1:numel(op)
    % Get the x and u vectors
    [xstruct,u] = LocalGetXU(op(ct));
    if ~isempty(xstruct)
        nx = sum([xstruct.signals.dimensions]);
        % Initialize the state perturbation levels
        if isempty(xpert_param)
            % Create a copy of the initial state matrix
            xpert = xstruct;
            % Loop over to write the states into the vector
            for ct2 = 1:length(xstruct.signals)
                xval = xstruct.signals(ct2).values;
                xpert.signals(ct2).values = relpert+1e-3*relpert*abs(xval);
            end
        elseif (numel(xpert_param) == 1) && (~isa(xpert_param,'opcond.OperatingPoint'))
            % Create a copy of the initial state matrix
            xpert = xstruct;
            % Loop over to write the states into the vector
            for ct2 = 1:length(xstruct.signals)
                xval = xstruct.signals(ct2).values;
                xpert.signals(ct2).values = xpert_param*ones(size(xval));
            end
        elseif isa(xpert_param,'opcond.OperatingPoint')
            % Get the state structure
            xpert = getstatestruct(xpert_param);
        elseif nx==length(xpert_param)
            opcopy = setxu(op(ct),xpert_param,upert);
            xpert = getstatestruct(opcopy);
        else
            % Clean up
            LocalModelCleanUp(ModelParameterMgr, ismodelcompiled)
            ctrlMsgUtils.error('Slcontrol:linearize:InvalidXPertOption',model)
        end
        
        % Make sure that the structure sorting order is in the order that the
        % simulink model expects.  This is because the order from the
        % derivatives and update calls will be in the order from the model.
        % Remove any unsupported states since they will not appear in the
        % operating point.
        model_struct = Simulink.BlockDiagram.getInitialState(model);
        model_struct = removeUnsupportedStates(slcontrol.Utilities,model_struct);
        
        % Make sure that the state perturbation is in the correct order
        xstruct = LocalSortStateStruct(xstruct,model_struct);
        xpert = LocalSortStateStruct(xpert,model_struct);
    else
        nx = 0;
        xpert = [];
    end
    
    % Initialize the input perturbation levels
    if isempty(upert_param)
        upert=relpert+1e-3*relpert*abs(u);
    elseif (numel(upert_param) == 1) && isa(upert_param,'double')
        upert=upert_param*ones(size(u));
    elseif isa(upert_param,'opcond.OperatingPoint')
        upert = [];
        for ct2 = 1:length(upert_param.Inputs)
            upert = [upert;upert_param.Inputs(ct2).u(:)];
        end
    elseif numel(upert_param) == numel(u)
        upert = upert_param;
    else
        % Terminate the compilation
        LocalModelCleanUp(ModelParameterMgr, ismodelcompiled)
        ctrlMsgUtils.error('Slcontrol:linearize:InvalidUPertOption',model)
    end
    
    try
        if ts == 0 && (nx == 0 || all(strcmp('CSTATE',{xstruct.signals.label})))
            [A,B,C,D] = pertlinearizecont(linutil,model,xstruct,u,xpert,upert,op(ct).t);
            % Create the linear model
            sys_iter = ss(A,B,C,D);
        else
            [A,B,C,D] = pertlinearizedisc(linutil,model,ts,xstruct,u,xpert,upert,op(ct).t);
            % Create the linear model
            sys_iter = ss(A,B,C,D,ts);
        end
    catch NumericalPertException
        % Clean up
        LocalModelCleanUp(ModelParameterMgr, ismodelcompiled)
        throwAsCaller(NumericalPertException)
    end
    
    % Store the state/input/and output names
    [~,x_str,~,~,statenames] = getStateNameFromStateStruct(slcontrol.Utilities,xstruct);
    iostruct.FullStateName = x_str;
    sys_iter.InputName = iostruct.InputName;
    sys_iter.OutputName = iostruct.OutputName;
    sys_iter.StateName = x_str;
    sys(:,:,ct) = sminreal(sys_iter); %#ok<AGROW>
end

% Return the state name and full block path for ordering
J = struct('stateBlockPath',{x_str},'stateName', {statenames});

% Reorder the states to match the order specified
sys = utOrderNameStates(linutil,model,sys,J,statenames,iostruct,LinData);

% Clean up
LocalModelCleanUp(ModelParameterMgr, ismodelcompiled)

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Local Utility
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iostruct = utGetIOStruct(ModelParameterMgr,J,opt,io,lintypeflag,varargin)
% UTGETIOSTRUCT
 
% Author(s): John W. Glass 19-Aug-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.59.2.1 $ $Date: 2010/07/26 15:40:16 $

% Get the port handles
inports = J.Mi.InputPorts;
outports = J.Mi.OutputPorts;
inname = J.Mi.InputName;
outname = J.Mi.OutputName;

% Logic to get the proper names and dimensions for each IO.
truncatename = strcmp(opt.UseFullBlockNameLabels,'off');
useBus = strcmp(opt.UseBusSignalLabels,'on');
iostruct = getioindices(linutil,ModelParameterMgr,io,inports,...
            outports,inname,outname,lintypeflag,truncatename,useBus,varargin{:});
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSortStateStruct - Sort the input state structure to be in the order
% of the model state structure order.
function xstruct = LocalSortStateStruct(xstruct,orderedstruct)

nsignals = numel(xstruct.signals);
indsort = zeros(nsignals,1);

for ct = 1:nsignals
    for ct2 = 1:nsignals
        % Does the block name match?
        blkcmp = strcmp(xstruct.signals(ct).blockName,orderedstruct.signals(ct2).blockName);
        % Does the state label match?
        labelcmp = strcmp(xstruct.signals(ct).label,orderedstruct.signals(ct2).label);
        % Does the sample time match?
        Tscmp = isequal(xstruct.signals(ct).sampleTime,orderedstruct.signals(ct2).sampleTime);
        % Does the statename match?
        stateNamecmp = strcmp(xstruct.signals(ct).stateName,orderedstruct.signals(ct2).stateName);
        
        if blkcmp && labelcmp && Tscmp && stateNamecmp
            indsort(ct2) = ct;
            continue;
        end
    end
end

% Sort the signals
xstruct.signals = xstruct.signals(indsort);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  [xstruct,u] = LocalGetXU(OP)
function [xstruct,u] = LocalGetXU(op)

% Get the state structure
xstruct = getstatestruct(op);

% Extract the input levels handle multivariable case
u = [];
for ct = 1:numel(op.Inputs)
    u = [u;op.Inputs(ct).u(:)];
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalEvalParam
function param = LocalEvalParam(paramval)

if isa(paramval,'char')
    param = str2double(paramval);
    if isnan(param)
        param = evalin('base',paramval);
    end
else
    param = paramval;
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalValidateOperatingPoint
function op = LocalValidateOperatingPoints(model,op,opt,isrunning)

if isempty(op)
    op = opcond.OperatingPoint(model);
    sync(op,false);
elseif ~isrunning
    % Check to see that the operating condition is up to date
    if strcmp(opt.ByPassConsistencyCheck,'off')
        for ct = 1:numel(op)
            try
                sync(op(ct),true);
            catch UpdateException
                % We do not need to terminate the compilation since the update
                % function will terminate when an error is found.
                throwAsCaller(UpdateException);
            end
        end
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalComputeSampleTime
%  Computes the sample time from the linearization options
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ts = LocalComputeSampleTime(options)

if ischar(options.SampleTime)
    try
        ts = evalin('base',options.SampleTime);
    catch Ex 
        ctrlMsgUtils.error('Slcontrol:linutil:InvalidSampleTimeExpression')
    end
else
    ts = options.SampleTime;
end
if ~isscalar(ts) || ~isfinite(ts) || ~isreal(ts) || (ts < 0 && ts ~= -1)
    ctrlMsgUtils.error('Slcontrol:linutil:InvalidSampleTimeExpression')
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCheckUniformSampleTime
%  Checks whether the set of linearization results have a shared sample
%  time and can be put in an LTI array, errors otherwise.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckUniformSampleTime(Data)
% Data might be a struct (snapshot case) or a cell array of LTI (op case)
for ct = numel(Data):-1:1
    if isstruct(Data)
        ts(ct) = Data(ct).sys.Ts;
    else
        ts(ct) = Data{ct}.Ts;
    end
end
sampletimes = unique(ts);
isUniform = (numel(sampletimes) == 1);
if ~isUniform
    % Error in the case of non-unique sample times
    % Construct a string that reports sample times in comma separated form
    tsstr = num2str(sampletimes(1));
    for ct = 2:numel(sampletimes)
        tsstr = [tsstr ', ' num2str(sampletimes(ct))];            
    end
    msgCore = ctrlMsgUtils.message('Slcontrol:linearize:NonUniformSampleTimeInLinResultsCore',tsstr);
    errCore = MException('Slcontrol:linearize:NonUniformSampleTimeInLinResultsCore', '%s', msgCore);    
    err = MException('Slcontrol:linearize:NonUniformSampleTimeInLinResultsCommand', '%s',...
        ctrlMsgUtils.message('Slcontrol:linearize:NonUniformSampleTimeInLinResultsCommand'));
    err = addCause(err,errCore);
    throwAsCaller(err);
end

end

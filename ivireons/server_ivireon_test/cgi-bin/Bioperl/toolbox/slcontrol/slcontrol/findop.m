function [oppoint,varargout] = findop(model,varargin)
%FINDOP Find operating points from specifications or simulation
%
%   [OP_POINT,OP_REPORT]=FINDOP('model',OP_SPEC) finds an operating point,
%   OP_POINT, of the model, 'model', from specifications given in OP_SPEC.
%
%   [OP_POINT,OP_REPORT]=FINDOP('model',OP_SPEC,OPTIONS) using several options
%   for the optimization are specified in the OPTIONS object, which you can
%   create with the function LINOPTIONS.
%
%   The input to findop, OP_SPEC, is an operating point specification object.
%   Create this object with the function OPERSPEC. Specifications on the
%   operating points, such as minimum and maximum values, initial guesses,
%   and known values, are specified by editing OP_SPEC directly or by using
%   get and set. To find equilibrium, or steady-state, operating points, set
%   the SteadyState property of the states and inputs in OP_SPEC to 1. The
%   FINDOP function uses optimization to find operating points that closely
%   meet the specifications in OP_SPEC. By default, findop uses the optimizer
%   fmincon. To use a different optimizer, change the value of OptimizerType
%   in OPTIONS using the LINOPTIONS function.
%
%   A report object, OP_REPORT, gives information on how closely FINDOP
%   meets the specifications. The function FINDOP displays the report
%   automatically, even if the output is suppressed with a semi-colon.
%   To turn off the display of the report, set DisplayReport to 'off' in
%   OPTIONS using the function LINOPTIONS.
%
%   OP_POINT=FINDOP('model',SNAPSHOTTIMES) runs a simulation of the model,
%   'model', and extracts operating points from the simulation at the
%   snapshot times given in the vector, SNAPSHOTTIMES. An operating point
%   object, OP_POINT, is returned.
%
%   See also OPERSPEC, LINOPTIONS

%  Author(s): John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.34.2.1 $ $Date: 2010/07/26 15:40:14 $

% If an options object is specified pass this to the operating condition
% spec object
error(nargchk(2, 5, nargin, 'struct'))

% Create the model parameter manager and make sure models are open
ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(model);
ModelParameterMgr.loadModels;

if isa(varargin{1},'opcond.OperatingSpec')
   op = varargin{1};
   if nargin > 2
      options = varargin{2};
   else
      options = linoptions;
   end
   
   % Make sure that the model name matches the operating point
   % specification.
   if ~strcmp(model,op.model)
      ctrlMsgUtils.error('Slcontrol:findop:ModelDoesNotMatchSpecification',model,op.model);
   end
   
   % Get the display function handle and arguments
   if nargin == 5
      % Display in the output function using this function handle for trim
      % the stop function is a function to check to stop the optimization.
      % The display function should be in the form a vector cell array where
      % the first element is a function handle.  The updated string then
      % will be added as a last argument.
      dispfcn = varargin{3};
      stopfcn = varargin{4};
   else
      % Otherwise display to the workspace for trim.  Use an empty variable
      % to optimize checking for this function during the optimization.
      dispfcn = [];
      stopfcn = [];
   end
   
   % Search for the operating point
   try
      [oppoint,opreport] = LocalTrimModel(ModelParameterMgr,op,options,dispfcn,stopfcn);
   catch OperpointSearchException
      throwAsCaller(OperpointSearchException)
   end
   
   if nargout == 2
      varargout{1} = opreport;
   end
elseif isa(varargin{1},'double')
   try
      % Run the simulation snapshot
      oppoint = runsnapshot(LinearizationObjects.OperPointSnapShotEvent(...
         ModelParameterMgr,varargin{1}));
      ModelParameterMgr.closeModels;
   catch SimSnapshotException
      ModelParameterMgr.closeModels;
      throwAsCaller(SimSnapshotException)
   end
else
   ctrlMsgUtils.error('Slcontrol:findop:InvalidOperatingPoint');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oppoint,opreport] = LocalTrimModel(ModelParameterMgr,op,options,dispfcn,stopfcn)

% Make sure the model is loaded
model = ModelParameterMgr.Model;

% Check to be sure that a single tasking solver is being used.
checkSingleTaskingSolver(linutil,model)

% If the user has the output constraints on set the analysis points for
% linearization get the output signal UDD block handles.
outs = op.Outputs;
bh = get_param(get(outs,{'Block'}),'Object');
bt = get([bh{:}],{'BlockType'});

% Determine whether to use analysis ports.  If all the output constraints
% are outports then use the standard model output evaluation function.
% Otherwise find all the source ports for the output constraints and mark
% them for linear analysis.
ios = [];
if ~all(strcmpi(bt,'Outport')) && ~isempty(bt) && strcmp(options.OptimizationOptions.Jacobian,'on')
   % The portflag determines whether or not to use the analysis ports for
   % linearization.
   portflag = true;
   % Get ready to create the I/O required for linearization
   h = linearize.IOPoint;
   h.Type = 'out';
   for ct = 1:length(bt)
      ios = [ios;h.copy];
      if strcmpi(bt(ct),'Outport')
         % Get the source block
         ios(ct).Block = [op.Model,'/',get_param(bh{ct}.PortConnectivity.SrcBlock,'Name')];
         % Get the source port
         ios(ct).PortNumber = bh{ct}.PortConnectivity.SrcPort + 1;
      else
         % Set the Block and PortNumber properties
         ios(ct).Block = outs(ct).Block;
         ios(ct).PortNumber = outs(ct).PortNumber;
      end
   end
   % Set the Analysis I/O properties for the input ports
   ins = op.Inputs;
   h.Type = 'in';
   for ct = 1:length(ins)
      ios = [ios;h.copy];
      ios(end).Block = ins(ct).Block;
      ios(end).PortNumber = 1;
   end
else
   % Otherwise don't use the analysis ports, do the root level if needed
   % linearization.
   portflag = false;
end

% Get the desired Simulink setparam properties
if numel(op.Inputs)
   useModelu = false;
else
   useModelu = true;
end


% Push the linearization points to the model if needed.
if portflag
   [ConfigSetParameters,ModelParams] = createLinearizationParams(linutil,false,useModelu,ios,op.Time,options);
   ModelParams.SimulationMode = 'normal';
   ModelParameterMgr.LinearizationIO = ios;
   ModelParameterMgr.ModelParameters = ModelParams;
   ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
   ModelParameterMgr.prepareModels('linearization');
else
   [ConfigSetParameters,ModelParams] = createLinearizationParams(linutil,false,useModelu,[],op.Time,options);
   ModelParams.SimulationMode = 'normal';
   ModelParameterMgr.ModelParameters = ModelParams;
   ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
   ModelParameterMgr.prepareModels('linearization');
end

% Compile the model.
try
   ModelParameterMgr.compile('lincompile');
catch CompileModelException
   ModelParameterMgr.restoreModels;
   ModelParameterMgr.closeModels;
   throwAsCaller(CompileModelException);
end

% Check to see that the operating condition is up to date
if strcmp(options.ByPassConsistencyCheck,'off')
   try
      sync(op,true);
   catch UpdateOperatingPointException
      % Clean up
      % Release the compiled model
      ModelParameterMgr.term;
      ModelParameterMgr.restoreModels;
      ModelParameterMgr.closeModels;
      throwAsCaller(UpdateOperatingPointException);
   end
end

% Create the optimization object
try
   % If the model is being trimmed with the analytic Jacobians error out if
   % there are transport delays with Pade orders greater then zero.
   if strcmp(options.OptimizationOptions.Jacobian,'on')
      tdelayblks = find_system(op.Model,'FollowLinks','on',...
         'regexp','on','BlockType','TransportDelay');
      for ct = 1:length(tdelayblks)
         tdelayrti = get_param(tdelayblks{ct},'RunTimeObject');
         if strcmp(get_param(tdelayblks{ct},'BlockType'),'TransportDelay')
            nonzeropade = tdelayrti.DialogPrm(6).Data > 0;
         elseif strcmp(get_param(tdelayblks{ct},'BlockType'),'VariableTransportDelay')
            nonzeropade = tdelayrti.DialogPrm(8).Data > 0;
         end
         
         if nonzeropade
            blk = regexprep(tdelayblks{ct},'\n',' ');
            ctrlMsgUtils.error('Slcontrol:findop:PadeOrderMustBeZero',blk)
         end
      end
      mdlrefblks = find_system(op.Model,'FollowLinks','on',...
         'regexp','on','BlockType','ModelReference');
      if any(strcmp(get_param(mdlrefblks,'SimulationMode'),'Accelerator'))
         ctrlMsgUtils.error('Slcontrol:findop:AccelJacobianNotSupported')
      end
   end
   
   switch options.OptimizerType
      case 'graddescent_elim'
         optim = OptimizationObjects.fmincon(op,options,ios);
      case 'graddescent'
         optim = OptimizationObjects.fmincon_xuvary(op,options,ios);
      case 'lsqnonlin'
         optim = OptimizationObjects.lsqnonlin(op,options,ios);
      case 'simplex'
         optim = OptimizationObjects.fminsearch(op,options);
   end
catch CreateOptimizerObject
   % Release the compiled model
   ModelParameterMgr.term;
   
   ModelParameterMgr.restoreModels;
   ModelParameterMgr.closeModels;
   % Throw the error
   throwAsCaller(CreateOptimizerObject);
end

% Set the display and stop functions
optim.dispfcn = dispfcn;
optim.stopfcn = stopfcn;

% Run the optimization
try
   [oppoint,opreport,exitflag,optimoutput] = optimize(optim);
catch SearchOperatingPointException
   % Release the compiled model
   ModelParameterMgr.term;
   
   ModelParameterMgr.restoreModels;
   ModelParameterMgr.closeModels;
   throwAsCaller(SearchOperatingPointException);
end

if (exitflag > 0)
   exitdata = ctrlMsgUtils.message('Slcontrol:findop:SuccessfulTermination');
elseif (exitflag == 0)
   exitdata = ctrlMsgUtils.message('Slcontrol:findop:MaximumFunctionEvalExceeded');
elseif (exitflag == -1)
   exitdata = ctrlMsgUtils.message('Slcontrol:findop:OptimizationTerminatedPrematurely');
elseif (exitflag == -2)
   exitdata = ctrlMsgUtils.message('Slcontrol:findop:CouldNotMeetConstraints');
else
   exitdata = ctrlMsgUtils.message('Slcontrol:findop:OptimizationDidNotConverge');
end

% Store the optimization data in the report
opreport.TerminationString = exitdata;
opreport.OptimizationOutput = optimoutput;

% Display the report of the optimization
if strcmp(options.DisplayReport,'on')
   disp(ctrlMsgUtils.message('Slcontrol:findop:OptimizationOutputDisplayTitle'));
   disp('---------------------------------');
   display(opreport);
elseif strcmp(options.DisplayReport,'iter') && isempty(dispfcn)
   fprintf(1,'\n%s\n\n',exitdata);
end

% Clean up
ModelParameterMgr.term;
ModelParameterMgr.restoreModels;
ModelParameterMgr.closeModels;

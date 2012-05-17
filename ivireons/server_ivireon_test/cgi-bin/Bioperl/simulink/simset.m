function options = simset(varargin)
%SIMSET Create or alter the  OPTIONS structure for input to SIM. 
%
% The SIMSET command is obsolete because of the single-output SIM command
% syntax. However, the SIMSET command will be maintained for the purpose of 
% backwards compatibility.
%
%   OPTIONS = SIMSET('NAME1',VALUE1,'NAME2',VALUE2,...) creates a Simulink
%   SIM options structure, OPTIONS, in which the named properties have
%   the corresponding specified values.  It is sufficient to type only the 
%   leading characters that uniquely identify the property.  Simulink 
%   ignores case for property names.
%
%   OPTIONS = SIMSET(OLDOPTS,'NAME1',VALUE1,...) alters an existing options
%   structure OLDOPTS.
%
%   OPTIONS = SIMSET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS. Simulink replaces any old 
%   properties with the corresponding new properties specified.
%
%   SIMSET with no input arguments displays all property names and their
%   possible values.
%
%   SIMSET PROPERTY DEFAULTS
%
%   The default for any unspecified property is the value specified in the 
%   Simulation Parameters dialog box if present.  If the value specified in 
%   the Simulation Parameters dialog box is "auto", then Simulink uses the 
%   following default values, respectively.
%
%   SIMSET PROPERTIES
%
%   Solver - Method to advance time [ VariableStepDiscrete |
%                                     ode45 | ode23 | ode113 | ode15s | 
%                                     ode23s | ode23t | ode23tb |
%                                     FixedStepDiscrete |
%                                     ode8 | ode5 | ode4 | ode3 | ode2 | ode1 |
%                                     ode14x ]
%
%   This property specifies which solver Simulink uses to advance time.
%
%   RelTol - Relative error tolerance [ positive scalar {1e-3} ]
%   This scalar applies to all components of the state vector.  The
%   estimated error in each integration step satisfies
%   e(i) <= max(RelTol*abs(x(i)),AbsTol(i)).  RelTol applies only to the
%   variable-step solvers, and defaults to 1e-3 (0.1% accuracy).
%
%   AbsTol - Absolute error tolerance [ positive scalar {1e-6} ]
%   This scalar applies to all components of the state vector.  AbsTol
%   applies only to the variable-step solvers, and defaults to 1e-6.
%
%   Refine - Output refinement factor [ positive integer {1} ]
%   This property increases the number of output points by the specified
%   factor, thus producing smoother output.  During refinement, the solver
%   also checks for zero crossings. Refine applies only to the variable-step
%   solvers and defaults to 1.  Refine is ignored if output times are
%   specified. 
%
%   MaxStep - Upper bound on the step size [ positive scalar {auto} ]
%   MaxStep applies only to the variable-step solvers, and defaults to
%   one-fiftieth of the simulation interval.
%
%   MinStep - Lower bound on the step size [ positive scalar {auto} ]
%   or [ positive scalar, nonnegative integer ]
%   Minstep applies only to the variable-step solvers, and defaults to 
%   a value based on your machine precision.
%
%   InitialStep - Suggested initial step size [ positive scalar {auto} ]
%   InitialStep applies only to the variable-step solvers.  The solver tries
%   a step size of InitialStep first.  By default, the solver determines
%   an initial step size automatically.
%
%   MaxOrder - Maximum order of ODE15S [ 1 | 2 | 3 | 4 | {5} ]
%   MaxOrder applies only to ODE15S, and defaults to 5.
%
%   FixedStep - Fixed step size [ positive scalar ]
%   FixedStep applies only to the fixed-step solvers.  If there are discrete
%   components, the default is the fundamental sample time; otherwise, the
%   default is one-fiftieth of the simulation interval.
%
%   ExtrapolationOrder - Order of extrapolation in ODE14X [ 1 | 2 | 3 | {4} ]
%   Order of extrapolation method that ODE14X uses. The default value is 4.
%
%   NumberNewtonIterations - Number of Newton iterations in ODE14X [ {1} ]
%   Number of iterations that ODE14X performs. The default value is 1. 
%
%   OutputPoints - Determine output points [ {specified} | all ]
%   OutputPoints defaults to 'specified', i.e., the solver produces outputs
%   T, X, and Y only at the times specified in TIMESPAN.  When OutputPoints
%   is set to 'all', the T, X, and Y also includes the time steps taken
%   by the solver.
%
%   OutputVariables - Set output variables [ {txy} | tx | ty | xy | t | x | y ]
%   If 't' or 'x' or 'y' is missing from the OutputVariables string, then
%   the solver produces an empty matrix in the corresponding output T, X,
%   or Y. Simulink ignores this property if there are no left-hand side 
%   arguments.
%
%   SaveFormat - Set save format [{'Array'} | 'Structure' | 'StructureWithTime'] 
%   This property specifies the format of states and outputs that Simulink 
%   saves. The state matrix contains continuous states followed by discrete  
%   states. If the save format is 'Structure' or 'StructureWithTime', then 
%   Simulink saves the states and the outputs in the structure arrays with 
%   time and signals fields. The signals field contains the following  
%   fields: 'values', 'label', and 'blockName'. If the save format is 
%   'StructureWithTime', then Simulink saves simulation time in the 
%   corresponding structures. 
%
%   MaxDataPoints - Limit number of data points [non-negative integer {0}]
%   'MaxDataPoints' was previously called 'MaxRows'. This property limits 
%   the number of data points returned in T, X, and Y to the last 
%   MaxDataPoints of the data logging time points.  If you specify 0, then  
%   Simulink does not impose any limit. MaxDataPoints defaults to 0.
%
%   Decimation - Decimation for output variables [ positive integer {1} ]
%   Simulink applies the decimation factor to the return variables, T, X, 
%   and Y. A decimation factor of 1 returns every data logging time point. 
%   A decimation factor of 2 returns every other data logging time point,
%   etc.  Decimation defaults to 1.
%
%   InitialState - Initial continuous and discrete states [ vector {[]} ]
%   The initial state vector consists of the continuous states (if any)
%   followed by the discrete states (if any).  InitialState supersedes the
%   initial states specified in the model.  InitialState defaults to the
%   empty matrix, [], indicating that Simulink uses the initial state values
%   specified in the model.
%
%   FinalStateName - Name of final states variable [ string {''} ]
%   Use this property to specify the name of the variable into which 
%   Simulink saves the states of the model at the end of the simulation.  
%   FinalStateName defaults to the empty string ''.
%
%   Trace - comma separated list of [ 'minstep', 'siminfo', 'compile', 
%                                     'compilestats' {''} ]
%   This property enables simulation tracing facilities.
%   o The 'minstep' trace flag specifies that simulation stops when the
%     solution changes so abruptly that the variable-step solvers cannot 
%     take a step and still satisfy the error tolerances.  By default 
%     Simulink issues a warning and continues the simulation.
%   o The 'siminfo' trace flag provides a short summary of the simulation
%     parameters in effect at the start of the simulation.
%   o The 'compile' trace flag displays the compilation phases of a block
%     diagram model.
%   o The 'compilestats' trace flag displays the time and memory usage for
%     the compilation phases of a block diagram model.
%
%   SrcWorkspace - Where to evaluate expressions [ {base} | current | parent ]
%   This property specifies the workspace in which to evaluate MATLAB
%   expressions defined in the model.  The default is the base
%   workspace.
%
%   DstWorkspace - Where to assign variables [ base | {current} | parent ]
%   This property specifies the workspace in which to assign any variables
%   defined in the model.  The default is the current workspace.
%
%   ZeroCross - Enable/disable location of zero crossings [ {on} | off ]
%   ZeroCross applies only to the variable-step solvers, and defaults to 
%   'on'.
%
%   SignalLogging - Enable/disable signal logging [ {on} | off ]
%   This property specifies whether or not to log signals that you 
%   identified for data logging.
%
%   SignalLoggingName - Name of port based logging variable [ string {''} ]
%   This property specifies the name of the variable into which to save
%   the port-based logging of the model at the end of the simulation.
%   SignalLoggingName defaults to the empty string, ''.
%
%   Debug - Enable/disable the Simulink debugger [ on | {off} ]
%   If you set this property to 'on', then the Simulink Debugger starts.
%
%   TimeOut - Error if the simulation is not done in [ positive scalar {Inf} ] 
%   seconds. If you run your model for a period longer than the value of 
%   TimeOut, then Simulink issues an error.
%
%   ConcurrencyResolvingToFileSuffix - Simulink appends this string to the
%   filename of the toFile block (before the extension). Currently, this 
%   property works only for Rapid Accelerator simulations. If you are 
%   simulating in Rapid Accelerator mode and you are calling SIM from  
%   PARFOR, then you must specify this suffix string.
%  
%   ReturnWorkspaceOutputs - Return the workspace outputs [on | {off}].
%   This option is valid only for Rapid Accelerator mode. If this option is  
%   turned 'on', then Simulink returns all of the outputs that are normally 
%   written to the workspace, to the right-most argument of the SIM command. 
%   For example, Simulink returns the ToWorkspace outputs and logging data  
%   the right-most (i.e., last) argument of the SIM command.
%
%   RapidAcceleratorUpToDateCheck - Enable/disable up-to-date check [{on} | off]
%   This option is valid only for Rapid Accelerator mode. If you turn this 
%   property 'off', then Simulink does not perform an up-to-date check. If 
%   you call SIM from PARFOR, then set this option to 'off'.
%
%   RapidAcceleratorParameterSets - Structure that contains run-time 
%   parameters.
%
%
%   See also SIM, SIMGET.

%   Mark W. Reichelt and John Ciolfi, 3/14/96
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.29.2.24 $

% Print out the possible values of the options.
if (nargin == 0) && (nargout == 0)
    slvrs = getSolversByParameter('SolverType','Variable Step','States','Discrete');
    fprintf('                    Solver: [');
    for i=1:length(slvrs)
        fprintf(' ''%s'' |',slvrs{i});
    end
    fprintf('\n');
    slvrs = getSolversByParameter('SolverType','Variable Step','States','Continuous');
    fprintf('                             ');
    for i=1:length(slvrs)
        fprintf(' ''%s'' |',slvrs{i});
    end
    fprintf('\n');
    
    slvrs = getSolversByParameter('SolverType','Fixed Step','States','Discrete');
    fprintf('                             ');
    for i=1:length(slvrs)
        fprintf(' ''%s'' |',slvrs{i});
    end
    fprintf('\n');
    slvrs = getSolversByParameter('SolverType','Fixed Step','States','Continuous');
    fprintf('                             ');
    for i=1:length(slvrs)-1
        fprintf(' ''%s'' |',slvrs{i});
    end
    fprintf(' ''%s'' ]\n',slvrs{end});
    
    fprintf('                    RelTol: [ positive scalar {1e-3} ]\n');
    fprintf('                    AbsTol: [ positive scalar {1e-6} ]\n');
    fprintf('                    Refine: [ positive integer {1} ]\n');
    fprintf('                   MaxStep: [ positive scalar {auto} ]\n');
    fprintf('                   MinStep: [ [positive scalar, nonnegative integer] {auto} ]\n');
    fprintf('     MaxConsecutiveMinStep: [ positive integer >=1]\n');
    fprintf('               InitialStep: [ positive scalar {auto} ]\n');
    fprintf('                  MaxOrder: [ 1 | 2 | 3 | 4 | {5} ]\n');
    fprintf('  ConsecutiveZCsStepRelTol: [ positive scalar {10*128*eps}]\n');
    fprintf('         MaxConsecutiveZCs: [ positive integer >=1]\n');
    fprintf('                 FixedStep: [ positive scalar {auto} ]\n');

    fprintf('        ExtrapolationOrder: [ 1 | 2 | 3 | {4} ]\n');
    fprintf('    NumberNewtonIterations: [ positive integer {1} ]\n');

    fprintf('              OutputPoints: [ {''specified''} | ''all'' ]\n');
    fprintf('           OutputVariables: [ {''txy''} | ''tx'' | ''ty'' | ''xy'' | ''t'' | ''x'' | ''y'' ]\n');
    fprintf('                SaveFormat: [ {''Array''} | ''Structure'' | ''StructureWithTime'']\n');
    fprintf('             MaxDataPoints: [ non-negative integer {0} ]\n');
    fprintf('                Decimation: [ positive integer {1} ]\n');
    fprintf('              InitialState: [ vector {[]} ]\n');
    fprintf('            FinalStateName: [ string {''''} ]\n');
    fprintf('                     Trace: [ comma separated list of ''minstep'', ''siminfo'', ''compile'', ''compilestats'' {''''}]\n');
    fprintf('              SrcWorkspace: [ {''base''} | ''current'' | ''parent'' ]\n');
    fprintf('              DstWorkspace: [ ''base'' | {''current''} | ''parent'' ]\n'); 
    fprintf('                 ZeroCross: [ {''on''} | ''off'' ]\n');
    fprintf('             SignalLogging: [ {''on''} | ''off'' ]\n');
    fprintf('         SignalLoggingName: [ string {''''} ]\n');
    fprintf('                     Debug: [ ''on'' | {''off''} ]\n');
    fprintf('                   TimeOut: [ positive scalar {Inf} ]\n');
    fprintf('      ConcurrencyResolvingToFileSuffix : [ string {''''} ]\n');
    fprintf('                 ReturnWorkspaceOutputs: [ ''on'' | {''off''} ]\n');
    fprintf('          RapidAcceleratorUpToDateCheck: [ ''on'' | {''off''} ]\n');
    fprintf('          RapidAcceleratorParameterSets: [ ''Structure'' ]\n');
    fprintf('\n');
    return;
end

Names = {
    'AbsTol'
    'Debug'
    'Decimation'
    'DstWorkspace'
    'FinalStateName'
    'FixedStep'
    'InitialState'
    'InitialStep'
    'MaxOrder'
    'ConsecutiveZCsStepRelTol'
    'MaxConsecutiveZCs'
    'SaveFormat'
    'MaxDataPoints'
    'MaxStep'
    'MinStep'
    'MaxConsecutiveMinStep'
    'OutputPoints'
    'OutputVariables'
    'Refine'
    'RelTol'
    'Solver'
    'SrcWorkspace'
    'Trace'
    'ZeroCross'
    'SignalLogging'
    'SignalLoggingName'
    'ExtrapolationOrder'
    'NumberNewtonIterations'
    'TimeOut'
    'ConcurrencyResolvingToFileSuffix'
    'ReturnWorkspaceOutputs'
    'RapidAcceleratorUpToDateCheck'
    'RapidAcceleratorParameterSets'
    };
m = size(Names);
names = lower(char(Names));

% Combine all leading options structures o1, o2, ... in simset(o1,o2,...).
options = [];
for j = 1:m
  options.(Names{j}) = [];
end
i = 1;
while i <= nargin
  arg = varargin{i};
  if ischar(arg)                         % arg is an option name
    break;
  end
  if ~isempty(arg)                      % [] is a valid options argument
    if ~isa(arg,'struct')
        DAStudio.error('Simulink:util:NotExpectedSimSetArgument', i);
    end
    for j = 1:m
      if any(strcmp(fieldnames(arg),deblank(Names{j})))
        val = arg.(Names{j});
      else
        val = [];
      end
      if ~isempty(val)
        options.(Names{j}) = val;
      end
    end
  end
  i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
  DAStudio.error('Simulink:util:NotNameValArguments');
end
expectval = 0;                       % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};

  if ~expectval
    if ~ischar(arg)
        DAStudio.error('Simulink:util:ExpectedStringPropertyName', i);
    end
    % For backward compatibility
    if(strcmpi(arg,'maxrows'))
        arg = 'MaxDataPoints';
    end
    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                    % if no matches
        DAStudio.error('Simulink:util:UnrecognizedPropertyName', arg);
    elseif length(j) > 1             % if more than one match
% Check for any exact matches (in case any names are subsets of others)
        k = strmatch(lowArg,names,'exact');
        if length(k) == 1
            j = k;
        else
            msg = Names{j(1)};
            for k = j(2:length(j))'
                msg = [msg ', ' Names{k}]; %#ok<AGROW>
            end
            DAStudio.error('Simulink:util:AmbiguousPropertyName',arg,msg);
        end
    end
    expectval = 1;                   % we expect a value next
    
  else
      options.(Names{j}) = arg;
      expectval = 0;

  end
  i = i + 1;
end

if expectval
    DAStudio.error('Simulink:util:ExpectedAValue', arg);
end

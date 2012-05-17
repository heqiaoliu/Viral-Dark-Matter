function initialize(this,opcond)
% INITIALIZE

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.16 $ $Date: 2008/03/13 17:39:22 $

% Store the time in a variable to be used repeatedly later
this.t = opcond.T;
this.model = opcond.model;
this.opcond = opcond;

% Get the user defined constraints
LocalInitializeConstraints(this);

% Set the new output fcn and optimization options
this.linoptions.OptimizationOptions.OutputFcn = @LocalOutputFcn;   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalInitializeConstraints(this)
% Function to get the state, input, output, and constraint vectors in 
% their proper order for the model in its current state.  

% Get information about the model, first get the state structure
xstruct = getStateStruct(slcontrol.Utilities,this.model);
                            
% The variables below are:
%   ncstates - the number of continuous states
%   indcstates - the indices into the state structure of the continuous
%   states.
%   x_str - A cell array of the states in the model.  This will be in the
%   order of the state structure and will be of length equal to the number 
%   of the trimmable states in the model.
%   x_statename - A list of the corresponding state names in the structure
[xstruct,x_str,ncstates,indcstates,x_statename] = getStateNameFromStateStruct(slcontrol.Utilities,xstruct);

% Store the state structure so that it does not have to be recreated
% during each iteration
this.statestructure = xstruct;

% Find the continuous states
this.ncstates = ncstates;
this.indcstates = indcstates;

% Compute the number of states in the structure
if isempty(xstruct.signals)
    nels = 0;
else    
    nels = sum([xstruct.signals.dimensions]);
end

% Initialize the vectors
x = zeros(nels,1); u = []; y = [];
ix = []; iu = []; iy = []; idx = [];
lbx = zeros(nels,1); lbu = []; lby = [];
ubx = zeros(nels,1); ubu = []; uby = [];

% Get the operating point specification
opcond = this.opcond;

% Find the unique state names
states = get(opcond.States,{'Block'});
state_unique = unique(states);

% Extract the states from the operating point specification object
for ct = 1:numel(state_unique)
    ind = find(strcmp(state_unique{ct},x_str));
    state_ind = find(strcmp(state_unique{ct},states));

    %% Unwrap all of the SimMechanics states
    if numel(state_ind) == 1
        NestedSetData(ind,state_ind)
    else
        %% Get the sample times for each of the states
        ts = get(opcond.States(state_ind),'Ts');
        %% Remove sample time offsets
        ts = [ts{:}];
        ts = ts(1:2:numel(ts)-1);
        %% Sort the sample times.  The sample times should be in the order
        %  Ts = [Ts_continuous, Ts_discrete_fast, ..., Ts_discrete_slow];
        [ts_sort,ind_sort] = sort(ts);
        %% Fill in the continuous state if there is one
        x_offset = 0;
        if any(ts_sort == 0)
            ind_cont = find(strcmp(get(opcond.States(state_ind),'SampleType'),'CSTATE'));
            % State name is not needed when there is one set of continuous
            % states
            if numel(ind_cont) == 1
                state_element = state_ind(ind_cont);
                nstates = opcond.States(state_element).Nx; 
                NestedSetData(ind(1:nstates),state_element)
                x_offset = x_offset + nstates;
            else
                for ct2 = 1:numel(ind_cont)
                    state_element = state_ind(ind_cont(ct2));
                    nstates = opcond.States(state_element).Nx;
                    StateName = opcond.States(state_element).StateName;
                    ind_statename = ind(strcmp(x_statename(ind),StateName));
                    NestedSetData(ind_statename,state_element)
                    x_offset = x_offset + nstates;
                end
            end
            ind_sort(ind_cont) = [];
        end
        %% Now fill in the remaining discrete states
        for ct2 = 1:numel(ind_sort)
            nstates = opcond.States(state_ind(ind_sort(ct2))).Nx;
            NestedSetData(ind((1:nstates)+x_offset),state_ind(ind_sort(ct2)));
            x_offset = x_offset + nstates;
        end
    end    
end

%% %
    function NestedSetData(ind,state_ind)

        x(ind) = opcond.States(state_ind).x(:);

        %% Find the known states
        ix = [ix;ind(opcond.States(state_ind).Known==true)];

        %% Get the actual initial values specified in the operating
        %% specification object.
        x(ind) = opcond.States(state_ind).x(:);

        %% Get the steady state values
        idx = [idx;ind(opcond.States(state_ind).SteadyState(:)==true)];

        %% Get the upper and lower bounds
        lbx(ind) = opcond.States(state_ind).Min(:);
        ubx(ind) = opcond.States(state_ind).Max(:);
    end
%% %

ix = sort(ix);
idx = sort(idx);

% Extract the input levels handle multivariable case
offset = 0;
for ct = 1:length(opcond.Inputs)    
    ind_known = find(opcond.Inputs(ct).Known);
    iu = [iu;offset+ind_known];    
    u_guess = opcond.Inputs(ct).u(:);
    u = [u;u_guess];

    offset = offset + opcond.Inputs(ct).PortWidth;
    lbu = [lbu;opcond.Inputs(ct).Min(:)];
    ubu = [ubu;opcond.Inputs(ct).Max(:)];
end

% Extract the output levels handle multivariable case
offset = 0;
for ct = 1:length(opcond.Outputs)
    ind_known = find(opcond.Outputs(ct).Known);
    iy = [iy;offset+ind_known];  
    y = [y;opcond.Outputs(ct).y(:)];
    
    offset = offset + opcond.Outputs(ct).PortWidth;
    lby = [lby;opcond.Outputs(ct).Min(:)];
    uby = [uby;opcond.Outputs(ct).Max(:)];
end

% Store the constraints
this.x0 = x; this.y0 = y; this.u0 = u;
this.ix = ix; this.iu = iu; this.iy = iy; this.idx = idx;
this.lbx = lbx; this.lbu = lbu; this.lby = lby;
this.ubx = ubx; this.ubu = ubu; this.uby = uby;

% Find the indices of the free states and inputs
this.indx = setxor(1:length(x),ix);
this.indu = setxor(1:length(u),iu);
this.indy = setxor(1:length(y),iy);

% Error out if there are no free constraints to optimize
if isempty([this.indx(:);this.indu(:)])
    ctrlMsgUtils.error('Slcontrol:findop:NoFreeVariablesToOptimize')
end

% Flush the states of any blocks that are integrators with external
% initial condtions
getOutputs(opcond,xstruct,u);

% Store the blocks that the constraints are on.  These names are used to
% for optimization progress.
this.StateConstraintBlocks = regexprep(x_str(this.idx),'\n',' ');
OutputConstraintBlocks = cell(length(y),1);
ctr = 1;
for ct1 = 1:length(opcond.Outputs)
    for ct2 = 1:opcond.Outputs(ct1).PortWidth
        OutputConstraintBlocks{ctr} = opcond.Outputs(ct1).Block;
        ctr = ctr + 1;
    end
end
this.OutputConstraintBlocks = OutputConstraintBlocks;

% Store the order of the blocks that the IO are specified.  Jacobian
% calculations must be ordered in the order for which the input and output
% constraints are specified.
if ~isempty(this.LinearizationIOs)
    outputs = this.LinearizationIOs(strcmp(get(this.LinearizationIOs,'Type'),'out'));
    OutputPointBlocks = cell(numel(y),1);
    for ct = 1:numel(outputs)
        OutputPointBlocks{ct} = outputs(ct).Block;
        ctr = ctr + 1;
    end
    this.OutputPointBlocks = OutputPointBlocks;

    inputs = this.LinearizationIOs(strcmp(get(this.LinearizationIOs,'Type'),'in'));
    InputPointBlocks = cell(numel(u),1);
    for ct = 1:numel(inputs)
        InputPointBlocks{ct} = inputs(ct).Block;
    end
    this.InputPointBlocks = InputPointBlocks;
else
    OutputPointBlocks = cell(numel(opcond.Outputs),1);
    for ct = 1:numel(opcond.Outputs)
        OutputPointBlocks{ct} = opcond.Outputs(ct).Block;
    end
    this.OutputPointBlocks = OutputPointBlocks;

    InputPointBlocks = cell(numel(opcond.Inputs),1);
    for ct = 1:length(opcond.Inputs)
        InputPointBlocks{ct} = opcond.Inputs(ct).Block;
    end
    this.InputPointBlocks = InputPointBlocks;    
end

% Get the output signal UDD block handles
this.BlockHandles = get_param(get(opcond.Outputs,{'Block'}),'Object');
this.PortNumbers = get(opcond.Outputs,{'PortNumber'});

% Find the Output Ports
if ~isempty(this.BlockHandles)
    bt = get([this.BlockHandles{:}],'BlockType');
    this.OutportHandles = find(strcmpi(bt,'Outport'));
    this.ConstrainedSignals = find(~strcmpi(bt,'Outport'));
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOutputFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stop = LocalOutputFcn(x, optimValues, state, this)

% Stop variable for the optimization
stop = false;

switch state
    case 'iter'
        LocalDisplayFcn(this,x)
        if ~isempty(this.stopfcn)
            stop = feval(this.stopfcn{:});
        end
    case 'interrupt'
        % Probably no action here. Check conditions to see
        % whether optimization should quit.
        if ~isempty(this.stopfcn)
            stop = feval(this.stopfcn{:});
        end
    case 'init'
        if strcmp(this.linoptions.DisplayReport,'iter')
            str = initdisplay(this);
            if ~isempty(this.dispfcn)
                feval(this.dispfcn{:},str);
            else
                for ct = 2:length(str)
                    disp(str{ct});
                end
            end
        end
    case 'done'
        % Cleanup of plots, guis, or final plot
        LocalDisplayFcn(this,x)
    otherwise
end
end

function LocalDisplayFcn(this,x)

if strcmp(this.linoptions.DisplayReport,'iter')
    % Update the errors since they may have changed
    this.UpdateErrors(x)
    if ~isempty(this.dispfcn)
        str = iterdisplayGUI(this);
        feval(this.dispfcn{:},str);
    else
        str = iterdisplay(this);
        for ct = 1:length(str)
            disp(str{ct});
        end
    end
end
end


function sync(this,Check)
% SYNC
%
 
% Author(s): John W. Glass 29-Jan-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/04/03 03:17:20 $

% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[NewInputs,ind_del_inports] = findNewInputs(this,Check);
if Check && (~isempty(NewInputs) || any(ind_del_inports))
    ctrlMsgUtils.error('SLControllib:opcond:OperatingPointNeedsUpdate',this.Model)
end
this.inputs(ind_del_inports) = [];
% Create the input constraint objects and populate their values
for ct = 1:length(NewInputs)
    newinput = opcond.InputSpec;
    newinput.Block = NewInputs{ct};
    this.inputs = [this.inputs;newinput];
end

% Update data
if ~isempty(this.inputs)
    update(this.inputs)
end

% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the outports in the model
[NewOuts,ind_old_del] = findNewOutputs(this);

% Create the output constraint objects and populate their values
if ~isempty(NewOuts) || any(ind_old_del)
    if Check
        ctrlMsgUtils.error('SLControllib:opcond:OperatingPointNeedsUpdate',this.Model)
    end
    this.outputs(ind_old_del) = [];
    for ct = 1:length(NewOuts)
        % Add a new output constraint
        newoutput = opcond.OutputSpec;
        newoutput.Block = NewOuts(ct).Block;
        newoutput.PortNumber = NewOuts(ct).PortNumber;
        this.outputs = [this.outputs;newoutput];
    end
end

% Update the data
if ~isempty(this.outputs)
    update(this.outputs)
end

% States %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the new states and delete the states that are no longer in the
% model.
[new_states,all_states,ind_old_del] = findNewStates(this,Check);

% Loop over each of the new states to get their upper and lower bound
% values if appropriate
new_states.signals = getStateConstraints(this,new_states.signals);

% Throw an error is requrested that the operation point must be updated
if Check && (~isempty(new_states.signals) || any(ind_old_del))
    ctrlMsgUtils.error('SLControllib:opcond:OperatingPointNeedsUpdate',this.Model)
end
this.states(ind_old_del) = [];
% Create the new state point objects
for ct = 1:length(new_states.signals)
    this.states = [this.states; opcond.StateSpec(new_states.signals(ct))];
end
% Update the state data if needed
if ~isempty(this.states)
    update(this.states,new_states,all_states)
end
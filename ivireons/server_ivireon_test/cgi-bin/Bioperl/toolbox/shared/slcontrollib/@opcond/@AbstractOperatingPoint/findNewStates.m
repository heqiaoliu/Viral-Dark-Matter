function [new_states,all_states,ind_old_del] = findNewStates(this,Check) 
% FINDNEWSTATES  Find the new states in a Simulink model and delete states
% in the operating point/spec object that no longer exist.
%
 
% Author(s): John W. Glass 12-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/01/29 15:37:05 $

% Get the state structure.  Use the getStateStruct method when the model is
% not compiled to ensure that any integrators are flushed.  If the
% operating point is being checked for inconsistencies do not flush the
% states.
flushstates = Check;
all_states = getStateStruct(slcontrol.Utilities,this.model,flushstates);

% Sort the state names
if ~isempty(all_states.signals)
    [blocknames,sortidx] = sort({all_states.signals.blockName});
    all_states.signals = all_states.signals(sortidx);
end

states = this.states;
ind_old_del = true(numel(states),1);
if isempty(states) || isempty(all_states)
    new_states = all_states;
    return
end

% Get the names of the blocks in the old state set
old_Blocks = get(states,{'Block'});
% Get the unique block names
blockName = {all_states.signals.blockName};
ublockName = unique(blockName);
ind_new_del = false(numel(all_states.signals),1);

% Find the states currently in the model that are in the
% current operating point (ind_new_del will delete these).  If
% the number of elements do not match delete the states in the
% current operating point.  This can happen when a user changes the
% name of a block.
for ct = 1:numel(ublockName)
    ind_new = find(strcmp(ublockName{ct},blockName));
    ind_old = find(strcmp(ublockName{ct},old_Blocks));
    loop_struct = all_states.signals(ind_new);
    loop_state = states(ind_old);
    [new_statename,sind_new] = sort({loop_struct.stateName});
    [old_statename,sind_old] = sort(get(loop_state,{'StateName'}));
    Nx_New = sort(cellfun(@numel,{loop_struct(sind_new).values}));
    Nx_Old = sort(cellfun(@numel,get(loop_state(sind_old),{'x'})));
    Ts_New = [loop_struct(sind_new).sampleTime];
    Ts_Old = get(loop_state,{'Ts'});Ts_Old = [Ts_Old{:}];
    inReferencedModel_New = [loop_struct(sind_new).inReferencedModel];
    inReferencedModel_Old = get(loop_state,{'inReferencedModel'});
    inReferencedModel_Old = [inReferencedModel_Old{:}];
    if (numel(ind_new) == numel(ind_old)) && ...
            isequal(new_statename(:),old_statename(:)) && ...
            isequal(Nx_New(:),Nx_Old(:)) && ...
            isequal(inReferencedModel_New,inReferencedModel_Old) && ...
            (isempty(Ts_Old) || isequal(Ts_New,Ts_Old))
        ind_new_del(ind_new) = true;
        ind_old_del(ind_old) = false;
    end
end
new_states = all_states;
new_states.signals(ind_new_del) = [];
function StateOrderList = updateStateOrder(oppoint,OldStateOrderList)
% UPDATESTATEORDER update the state order given a cell array of states and
% an operating point.
 
% Author(s): John W. Glass 26-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/12/04 23:27:21 $

% Set the state ordering cell array
ensureOpenModel(slcontrol.Utilities,oppoint.Model)
StateOrderList = getNonAccelReferenceStateBlockNames(oppoint);

% Loop over the state objects
ind = [];indState = (1:length(StateOrderList))';
for ct = 1:length(OldStateOrderList)
    stateind = find(strcmp(OldStateOrderList(ct),StateOrderList));
    indState(stateind) = 0;
    ind = [ind;stateind];
end

% Write the state order list back to the operating point task
OldStates = StateOrderList(ind);
NewStates = StateOrderList(indState ~= 0);
StateOrderList = [OldStates;NewStates];
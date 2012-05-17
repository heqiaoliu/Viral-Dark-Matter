function struct_element = findStateStructElement(state,state_struct)
% FINDSTATESTRUCTELEMENT  Find the state structure element given either a
% StatePoint of StateSpec object
%
 
% Author(s): John W. Glass 12-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/01/15 18:57:03 $

% Get the state name from the state structure
StateName = {state_struct.signals.blockName};
    
% Find the index into the state structure
ind_struct = find(strcmp(StateName,state.Block));
if numel(ind_struct) > 1
    for ct2 = 1:numel(ind_struct)
        if any(state.Ts == state_struct.signals(ind_struct(ct2)).sampleTime) && ...
                strcmp(state.SampleType,state_struct.signals(ind_struct(ct2)).label) && ...
                strcmp(state.StateName,state_struct.signals(ind_struct(ct2)).stateName)
            ind_struct = ind_struct(ct2);
            break
        end
    end
end

struct_element = state_struct.signals(ind_struct);
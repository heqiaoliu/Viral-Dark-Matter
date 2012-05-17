function id = new_state_output_data(stateId)
%NEW_STATE_OUTPUT_DATA( stateId )
%  **** This function is for internal use!
%  **** It should not be used directly from the command line.

%   E. Mehran Mestchian
%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.7.2.3 $  $Date: 2007/07/31 20:16:40 $

[chartId, stateName] = sf('get',stateId,'state.chart','state.name');

% If state name does not contain a significant word then creating a new state output data is pointless!
if isempty(regexp(stateName,'\w*','once'))
	id = 0;
	return;
end

id = sf('new','data'...
	,'.linkNode.parent', chartId...
	,'.name', stateName...
	,'.scope', 'OUTPUT_DATA'...
	,'.outputState',stateId...
);

sf('set', id, '.props.type.primitive', 'SF_BOOLEAN_TYPE');

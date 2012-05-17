function compute_state_enums(file,chart)

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.2.2.6 $  $Date: 2005/12/19 07:56:49 $
   global gChartInfo

	if ~isempty(gChartInfo.states)
		for state = [chart,gChartInfo.states]
			subStates = sf('SubstatesOf',state);
			if(~isempty(subStates))
				switch sf('get',state,'.decomposition')
				case 0  % CLUSTER_STATE
					for substate = subStates
						enumStr = ['IN_',sf('CodegenNameOf',substate)];
						sf('set',substate,'.activeChildEnumString',enumStr);
					end
				case 1  % SET_STATE
				otherwise,
					construct_coder_error(state,'Bad decomposition.');
				end
			end
		end
	end


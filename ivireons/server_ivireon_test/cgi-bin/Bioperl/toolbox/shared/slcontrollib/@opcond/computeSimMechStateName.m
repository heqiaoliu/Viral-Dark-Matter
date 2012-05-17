function StateName = computeSimMechStateName(state,state_ind) 
% COMPUTESIMMECHSTATENAME  Compute the state name for a SimMechanics state
% based on a State*SimMech object.
%
 
% Author(s): John W. Glass 14-Feb-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/04/25 03:19:28 $

% Find the path relative to the model name
statename = state.SimMechBlockStates{state_ind};
slashes = strfind(statename,'/');
StateName = statename(slashes(1)+1:end);
% Remove //'s since they do not denote a level or heirarchy
StateName = regexprep(StateName,'//','');
% Replace subsystem /'s with _'s
StateName = regexprep(StateName,'/','_');
% Replace the last two :'s with .'s
colons = strfind(StateName,':');
StateName(colons(end-1:end)) = '.';
% Remove remaining problem characters expect [a-z] (all case), _, and ..
ind_char = regexp(StateName,'[A-Z]','ignorecase');
ind_num = regexp(StateName,'[0-9]');
ind_und = regexp(StateName,'_');
ind_period = regexp(StateName,'\.');
ind = sort([ind_char,ind_num,ind_und,ind_period]);
StateName = StateName(ind);
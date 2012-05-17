function useFlagsAlgm = truth_table_gen_use_flags_algorithm(fcnId)
% --- Check for using flagword algorithm (generally faster)
%
%       if flagword feature is ON
%                 AND
%         chart C-bitops option is ON
%                 AND
%       number of conditions < 32
%
%     then enable flagword algorithm

% Copyright 2004-2005 The MathWorks, Inc.

fcnObj = idToHandle(sfroot, fcnId);
numP = size(fcnObj.conditionTable, 1) - 1;

useFlagsAlgm = sf('Feature', 'Truth Table flags algorithm') && ...
               (numP < 32);

if useFlagsAlgm && isa(fcnObj.Chart, 'Stateflow.Chart')
    useFlagsAlgm = useFlagsAlgm && fcnObj.Chart.EnableBitOps;
end

return;

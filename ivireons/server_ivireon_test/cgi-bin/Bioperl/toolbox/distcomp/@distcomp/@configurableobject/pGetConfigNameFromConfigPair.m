function configOut = pGetConfigNameFromConfigPair(config1, config2)
; %#ok Undocumented
%pGetConfigurationNameAfterMerge Deduce configuration after a merge
%
% If a simultaneous set of several configurations occures - deduce if the
% result should have a configuration value, or an empty name
%
% configOut = pGetConfigurationNameAfterMerge(obj, config1, config2) 

%  Copyright 2008 The MathWorks, Inc.

if ~isempty(config1) && isequal(config1, config2)
    configOut = config1;
else
    configOut = '';
end
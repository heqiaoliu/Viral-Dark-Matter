function supports_ipp = compiler_supports_eml_ipp(compilerName)

%   Copyright 2008-2010 The MathWorks, Inc.

supports_ipp = true;
if strcmp(compilerName, 'lcc') || ...
   strcmp(compilerName, 'openwatc')
   supports_ipp = false;
end

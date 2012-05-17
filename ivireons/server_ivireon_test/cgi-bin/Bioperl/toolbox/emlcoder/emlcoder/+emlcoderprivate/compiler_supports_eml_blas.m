function ok = compiler_supports_eml_blas(compilerName)

%   Copyright 2008 The MathWorks, Inc.

supported_compiler = true;
if strcmp(compilerName, 'intelc91msvs2005') || ...
   strcmp(compilerName, 'intelc11msvs2008') || ...	
   strcmp(compilerName, 'openwatc') || ...
   strcmp(compilerName, 'borland')
   supported_compiler = false;
end
ok = supported_compiler;
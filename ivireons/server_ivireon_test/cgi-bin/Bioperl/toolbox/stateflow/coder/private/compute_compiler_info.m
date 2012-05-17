function compute_compiler_info

%   Copyright 1995-2009 The MathWorks, Inc.

global gTargetInfo

gTargetInfo.compilerName = figure_out_the_required_compiler();
gTargetInfo.codingMSVCMakefile  = 0;
gTargetInfo.codingWatcomMakefile  = 0;
gTargetInfo.codingBorlandMakefile = 0;
gTargetInfo.codingLccMakefile     = 0;
gTargetInfo.codingUnixMakefile    = 0;
gTargetInfo.codingIntelMakefile   = 0;

if ~gTargetInfo.codingSFunction
   return;
end

switch gTargetInfo.compilerName
    case {'msvc60','msvc80','msvc90','msvc100'}
        gTargetInfo.codingMSVCMakefile    = 1;
    case 'lcc'
        gTargetInfo.codingLccMakefile     = 1;
    case 'unix'
        gTargetInfo.codingUnixMakefile    = 1;
    case 'watcom'
        gTargetInfo.codingWatcomMakefile  = 1;
    case {'intelc91msvs2005','intelc11msvs2008'}
        gTargetInfo.codingIntelMakefile   = 1;
    case 'borland'
        gTargetInfo.codingBorlandMakefile = 1;
    otherwise
        % WISH internal error
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compilerName = figure_out_the_required_compiler

% first, check if you are running on Unix i.e, not running on Windows
if isunix
    compilerName = 'unix';
    return;
end

compilerInfo = sf('Private','compilerman','get_compiler_info');
compilerName = compilerInfo.compilerName;

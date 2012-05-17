function obj = pbsproscheduler( proxyScheduler )
; %#ok Undocumented
%PBSPROSCHEDULER constructor for PBSPro scheduler

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:47 $

obj = distcomp.pbsproscheduler;

infoStruc = pParseOutputFromQstat( obj );

useJA     = iCheckPBSProVersion( infoStruc );
resource  = '-l select=^N^';
rshCmd    = 'pbs_remsh';

% PBS_RCP is "not designed" for general purpose file staging
if isunix
    rcpCmd = 'rcp';
else
    % Binary mode for transferring zip files
    rcpCmd = 'rcp -b';
end
    
useAttach = isunix; % PBS_ATTACH only exists on UNIX
if useJA
    stateinds = {'BRE', ...
                 'HQSTUW'};
else
    stateinds = {'RE', ...
                 'HQW'};
end

if ispc
    workerType = 'pc';
else
    workerType = 'unix';
end

set( obj, ...
     'Type', 'PBSPro', ...
     'Storage', handle(proxyScheduler.getStorageLocation), ...
     'ServerName', infoStruc.server, ...
     'ResourceTemplate', resource, ...
     'ClusterOsType', workerType, ...
     'UseJobArrays', useJA, ...
     'RcpCommand', rcpCmd, ...
     'RshCommand', rshCmd, ...
     'UsePbsAttach', useAttach, ...
     'StateIndicators', stateinds, ...
     'HasSharedFilesystem', true );

obj.setupForParallelExecution( workerType );

% This class accepts configurations and uses the scheduler section.
sectionName = 'scheduler';
obj.pInitializeForConfigurations(sectionName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function useJA = iCheckPBSProVersion( infoStruc )

% Pick the first set of digits following "PBSPro_"
PBSPro_major_ver = regexp( infoStruc.pbs_version, ...
                           '(?<=PBSPro_)[0-9]+', 'match', 'once' );
verNum           = str2double( PBSPro_major_ver );

if isempty( PBSPro_major_ver ) || isnan( verNum )
    warning( 'distcomp:pbsproscheduler:pbsversion', ...
             ['The PBSPro scheduler type is being used with a possibly incompatible version of PBS.\n', ...
              'The use of job arrays has been disabled.\n', ...
              ' The version of PBS we detected was:\n"%s"'], infoStruc.pbs_version );
    useJA  = false;
else
    if verNum >= 7
        useJA = true;
    else
        useJA = false;
        warning( 'distcomp:pbsproscheduler:oldVersion', ...
                 ['The PBSPro scheduler is being used with PBS Pro version "%s". \n', ...
                  'The use of job arrays has been disabled'], PBSPro_ver );
    end
end

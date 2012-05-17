function deleteContents(ss)
% Simulink.SubSystem.deleteContents deletes contents of a subsystem.
%
% Simulink.SubSystem.deleteContents deletes contents of a subsystem, i.e.,
% blocks, lines, notes (annotations).
%  Usage: 
%    Simulink.SubSystem.deleteContents(ss)
%  Input:
%    ss: a subsystem name or handle

%  Copyright 1994-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $
    
    if nargin ~= 1
        DAStudio.error('Simulink:modelReference:slSSDeleteContentsInvalidNumInputs');
    end

    % The input must be a subsystem name or handle
    try
        isSubsys = strcmpi(get_param(ss,'type'), 'block') && ...
            strcmpi(get_param(ss,'blocktype'), 'Subsystem');
    catch
        isSubsys = false;
    end
    
    if ~isSubsys
        DAStudio.error('Simulink:modelReference:slSSDeleteContentsInvalidInput');
    end
    
    bd = bdroot(ss);
    simStatus = get_param(bd,'SimulationStatus');
    if ~strcmpi(simStatus, 'stopped')
        bdName= get_param(bd, 'name');
        DAStudio.error('Simulink:modelReference:slBadSimStatus', bdName, simStatus);
    end
    
    % Now delete contents.  Undocumented APIs. Do not use them directly
    obj = get_param(ss, 'object');
    obj.deleteContent();
    
%end function
    
function deleteContents(bd)
% Simulink.BlockDiagram.deleteContents deletes contents of a block diagram.
%
% Simulink.BlockDiagram.deleteContents deletes contents, i.e., blocks, lines, 
% notes (annotations), of a block diagram. The block diagram must have
% already been loaded.
%
% Usage: Simulink.BlockDiagram.deleteContents(bd)
% Input:
%    bd: a block diagram name or handle
%

%   Copyright 1994-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
    
    if nargin ~= 1
        DAStudio.error('Simulink:modelReference:slBDDeleteContentsInvalidNumInputs');
    end
    
    try
        isBd = strcmpi(get_param(bd,'type'), 'block_diagram');
    catch
        isBd = false;
    end
    
    if ~isBd
        DAStudio.error('Simulink:modelReference:slBDDeleteContentsInvalidInput');
    end
    
    simStatus = get_param(bd,'SimulationStatus');
    if ~strcmpi(simStatus, 'stopped')
        bdName= get_param(bd, 'name');
        DAStudio.error('Simulink:modelReference:slBadSimStatus', bdName, simStatus);
    end
    
    % Now delete contents.  Undocumented APIs. Do not use them directly
    obj = get_param(bd, 'object');
    obj.deleteContent();
    
%end function
function createSubSystem(handles)
% Simulink.BlockDiagram.createSubSystem creates a new subsystem.
%
% Simulink.BlockDiagram.createSubSystem creates a new subsystem, from an
% array of block handles. 
% The blocks must all belong to the same system or subsystem to begin
% with.
%
% If called with no arguments, it creates a subsystem containing the
% selected blocks in the current system.
%
% Usage: Simulink.BlockDiagram.createSubsystem(handles)
% Input:
%    handles: an array of Simulink handles
%
%   Copyright 2008 The MathWorks, Inc.
    
    if nargin == 0
        selected = find_system(gcs, 'SearchDepth', 1, 'Selected', 'on');
        gcsIndex = find(ismember(selected, gcs)==1);
        if (gcsIndex)
            selected(gcsIndex) = [];
        end
        handles = cell2mat(get_param(selected, 'Handle'))';
    end
    
    handlesSize = size(handles);
    if (handlesSize(1) > 1)
        handles = handles';
    end
    
    obj = get_param( bdroot(gcs), 'Object');
    obj.localCreateSubSystem(handles);
     
%end function
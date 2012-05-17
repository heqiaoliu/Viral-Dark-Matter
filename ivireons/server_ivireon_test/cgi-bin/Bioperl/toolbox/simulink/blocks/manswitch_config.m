function manswitch_config(action)
%MANSWITCH_CONFIG Manual Switch block helper function.

% Remove/Add the S-function block to the Manual Switch masked 
% subsystem.
% Copyright 1990-2007 The MathWorks, Inc.

if nargin<1
    action = 'init';
end
    

manSwitchBlk       = gcb;
manSwitchBlkHandle = gcbh;

sfunBlock=find_system(manSwitchBlkHandle, ...
                      'LookUnderMasks','all' , ...
                      'FollowLinks'   ,'on'  , ...
                      'Name'          ,'S-Function'  ...
                      );
isExtern = strcmp( get_param(bdroot(manSwitchBlkHandle),...
                             'SimulationMode'),'external');

if strcmpi(action,'init')
    if(sfunBlock)
        if(~rtwenvironmentmode(bdroot(manSwitchBlkHandle)) || isExtern)
            % Remove the S-function block during code generation or external mode
            delete_block(sfunBlock);
            sPorts = get_param([manSwitchBlk '/SwitchControl'],'PortHandles');
            sLine = get_param(sPorts.Inport(2),'Line');
            delete_line(sLine);
            cPorts = get_param([manSwitchBlk '/Constant'],'PortHandles');
            cLine = get_param(cPorts.Outport(1),'Line');
            delete_line(cLine);
            add_line(manSwitchBlk,['Constant/1'], ['SwitchControl/2'])
        end
    else
        if(~isExtern && rtwenvironmentmode(bdroot(manSwitchBlkHandle)))
            % Add the S-function block during normal simulation
            add_block('built-in/S-Function',[manSwitchBlk '/S-Function'], 'Position','[135  79 230 111]');
            sPorts = get_param([manSwitchBlk '/SwitchControl'],'PortHandles');
            sLine = get_param(sPorts.Inport(2),'Line');
            delete_line(sLine);
            add_line(manSwitchBlk,['S-Function/1'], ['SwitchControl/2']);
            add_line(manSwitchBlk,['Constant/1'], ['S-Function/1']);
            set_param([manSwitchBlk '/S-Function'], 'FunctionName','sfblk_manswitch')
        end
    end
    
    isAccel = strcmp(get_param(bdroot(manSwitchBlkHandle),'RunningAccelerator')...
                     ,'on');
    if isAccel
    % set the Inport blocks to be test point
    % This is to force the disabling of the conditional input branch execution
    % optimization for this switch block.
    add_testpoints;
    set_switch_RunInEngine;
    else
    remove_testpoints;
    end
elseif strcmpi(action,'stop')
    remove_testpoints;
end
%======================================================================
% Nested functions 
%
% Note: All nested functions cache and reset the Dirty flag of the diagram.
%======================================================================
    %--------------------------------------------------------
    % Remove test points at the inport blocks
    function remove_testpoints
        oldDirty = get_param(bdroot(manSwitchBlk),'Dirty');
        InBlk = find_system(manSwitchBlk, 'LookUnderMasks','all',...
            'SearchDepth',1,...
            'FollowLinks', 'on', 'BlockType', 'Inport');
        for i=1:length(InBlk)
            PortHandle = get_param(InBlk{i}, 'PortHandles');
            set_param(PortHandle.Outport, 'TestPoint','off');
        end
        set_param(bdroot(manSwitchBlk),'Dirty',oldDirty);
    end
    %-----------------------------------------------------
    % Add test points at the inport blocks
    function add_testpoints
        oldDirty = get_param(bdroot(manSwitchBlk),'Dirty');
        InBlk = find_system(manSwitchBlk, 'LookUnderMasks','all',...
            'SearchDepth',1,...
            'FollowLinks', 'on', 'BlockType', 'Inport');
        for i=1:length(InBlk)
            PortHandle = get_param(InBlk{i}, 'PortHandles');
            set_param(PortHandle.Outport, 'TestPoint','on');
        end
        set_param(bdroot(manSwitchBlk),'Dirty',oldDirty);
    end
    %--------------------------------------------------------
    % Set the RunInEngine flag
    function set_switch_RunInEngine
        oldDirty = get_param(bdroot(manSwitchBlk),'Dirty');
        switchBlock=find_system(manSwitchBlk,...
            'LookUnderMasks','all' , ...
            'SearchDepth',1,...
            'FollowLinks'   ,'on'  , ...
            'Name'          ,'SwitchControl'  ...
            );
        if ~isempty(switchBlock)
            switchBlock = switchBlock{1};
            set_param(switchBlock, 'RunInEngine', 'on');
        end
        set_param(bdroot(manSwitchBlk),'Dirty',oldDirty);
    end
end
function name = getUniqueSignalName(this,port,varargin)
% GETUNIQUESIGNALNAME - Gets the unique signal name port a port.  This
% method will search through model to find all the signals of the same name
% and then will search to get a unique block parent.  If there is no signal
% name return the truncated block path.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/10/31 06:58:36 $

%% Get name of the port handling the /'s in the signal name
name = get_param(port,'Name');
  
%% If it is empty use a truncated block name
if ~isempty(name)
    %% Get the block name
    block = regexprep(get_param(port,'Parent'),'\n',' ');
    %% Find the shortest representation of the name for the block
    block_diagram = this.getModelHandleFromBlock(block);
    ports = find_system(block_diagram.Name,...
        'findall','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','port',...
        'Name',name);
    %% Get the block parents
    blocks = get_param(ports,'Parent');
    %% Remove the new line and carriage returns in the model/block name
    blocks = regexprep(blocks,'\n',' ');
    %% Make into a cell array if needed
    if ischar(blocks)
        blocks = {blocks};
    end     
    %% If the block parents are unique
    if (length(blocks) == length(unique(blocks)))
        %% Get the index into the blocks list
        blk_ind = find(strcmp(block,blocks));
        %% Tack the signal name to the block name
        for ct = 1:length(blocks)
            blocks{ct} = sprintf('%s/%s',blocks{ct},regexprep(name,'/','//'));
        end
        unblks = uniqname(this,blocks,true);
        name = regexprep(unblks{blk_ind},'//','/');   
    else
        % Identical block, prepend block name and append integer to signal name
        ctrlMsgUtils.warning('Slcontrol:linearize:SignalLabelConflict');
        % Find the ports corresponding to the identical block
        ports_block = ports(strcmp(block,blocks));
        % Find the current port among those ports and append its indice
        p_ind = find(port == ports_block);
        name = sprintf('%s/%s(%d)',get_param(block,'Name'),name,p_ind);
    end
else
    if nargin > 2
        name = this.getUniqueBlockName(get_param(port,'Parent'),varargin{1});
    else
        name = this.getUniqueBlockName(get_param(port,'Parent'));
    end
end

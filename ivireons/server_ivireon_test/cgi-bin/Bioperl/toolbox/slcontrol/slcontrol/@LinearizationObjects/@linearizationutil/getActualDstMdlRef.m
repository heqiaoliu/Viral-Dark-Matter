function dst_ports = getActualDstMdlRef(this,port,topmdl,normalmdlblks)
% GETACTUALDSTMDLREF  Get the actual destinations walking through model
% references.
%

% Author(s): John W. Glass 28-Mar-2007
%   Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/04/11 20:40:52 $

dst_ports = zeros(0,4);
LocalRecurseDst(port)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function LocalRecurseDst(port)

        act_dst = port.getActualDst;

        for ct_dst = 1:size(act_dst,1)
            dst_parent = get_param(act_dst(ct_dst,1),'Parent');
            try
                dst_block = get_param(dst_parent,'Handle');
                dst_block_type = get_param(dst_block,'BlockType');
                if strcmp(dst_block_type,'ModelReference') && ...
                        strcmp(get_param(dst_block,'SimulationMode'),'Normal')
                    % Walk into the model reference
                    refmdl = get_param(dst_block,'NormalModeModelName');
                    dst_port = get_param(act_dst(ct_dst,1),'PortNumber');
                    % Get the input port in the referenced model
                    dst_port_str = sprintf('%d',dst_port);
                    root_inport = find_system(refmdl,'SearchDepth',1,...
                        'BlockType','Inport','Port',dst_port_str);
                    root_ports = get_param(root_inport{1},'PortHandles');
                    root_port = handle(root_ports.Outport(1));
                    LocalRecurseDst(root_port);
                elseif strcmp(dst_block_type,'Outport') && ...
                        ~strcmp(bdroot(dst_parent),topmdl)
                    % Walk out of the model reference
                    % Find the parent model
                    normalmdlblk = normalmdlblks{strcmp(...
                        get_param(normalmdlblks,'NormalModeModelName'),...
                        getfullname(bdroot(dst_block)))};
                    % Get the output port in the referenced model
                    mdl_ports = get_param(normalmdlblk,'PortHandles');
                    mdl_portnumber = str2double(get_param(dst_block,'Port'));
                    mdl_port = handle(mdl_ports.Outport(mdl_portnumber));
                    LocalRecurseDst(mdl_port);
                else
                    dst_ports(end+1,:) = act_dst(ct_dst,:);
                end
            catch DestionationException
                if strcmp(DestionationException.identifier,'Simulink:Commands:InvSimulinkObjectName')
                    % This is the case of a bus expanded block in the model
                    % where we don't need to worry about a model reference
                    % destination.
                    dst_ports(end+1,:) = act_dst(ct_dst,:);
                else
                    throwAsCaller(DestionationException);
                end
            end
        end
    end
end

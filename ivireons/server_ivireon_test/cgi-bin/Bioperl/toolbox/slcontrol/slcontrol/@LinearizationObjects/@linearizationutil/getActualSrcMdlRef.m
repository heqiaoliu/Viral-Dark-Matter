function src_ports = getActualSrcMdlRef(this,port,topmdl,normalmdlblks) 
% GETACTUALSRCMDLREF  Get the actual sources walking through model
% references.
%
 
% Author(s): John W. Glass 28-Mar-2007
%   Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/11 20:40:53 $

src_ports = zeros(0,3);
LocalRecurseSrc(port)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function LocalRecurseSrc(port)

        act_src = port.getActualSrc;
        for ct_src = 1:size(act_src,1)
            dst_parent = get_param(act_src(ct_src,1),'Parent');
            try
                dst_block = get_param(dst_parent,'Handle');
                dst_block_type = get_param(dst_block,'BlockType');
                if strcmp(dst_block_type,'ModelReference') && ...
                    strcmp(get_param(dst_block,'SimulationMode'),'Normal')
                    % Walk into the model reference
                    refmdl = get_param(dst_block,'NormalModeModelName');
                    dst_port = get_param(act_src(ct_src,1),'PortNumber');
                    % Get the input port in the referenced model
                    dst_port_str = sprintf('%d',dst_port);
                    root_outport = find_system(refmdl,'SearchDepth',1,...
                                'BlockType','Outport','Port',dst_port_str);
                    root_ports = get_param(root_outport{1},'PortHandles');
                    root_port = handle(root_ports.Inport(1));
                    LocalRecurseSrc(root_port);                   
                elseif strcmp(dst_block_type,'Inport') && ...
                        (bdroot(dst_block)~=get_param(topmdl,'Handle'))
                    % Walk out of the model reference
                    % Find the parent model
                    normalmdlblk = normalmdlblks{strcmp(...
                            get_param(normalmdlblks,'NormalModeModelName'),...
                            getfullname(bdroot(dst_block)))};
                    % Get the output port in the referenced model
                    mdl_ports = get_param(normalmdlblk,'PortHandles');
                    mdl_portnumber = str2double(get_param(dst_block,'Port'));
                    mdl_port = handle(mdl_ports.Inport(mdl_portnumber));
                    LocalRecurseSrc(mdl_port);    
                else
                    src_ports(end+1,:) = act_src(ct_src,:);
                end
            catch SourceException
                if strcmp(SourceException.identifier,'Simulink:Commands:InvSimulinkObjectName')
                    % This is the case of a bus expanded block in the model
                    % where we don't need to worry about a model reference
                    % source.
                    src_ports(end+1,:) = act_src(ct_src,:);
                else
                    throwAsCaller(SourceException);
                end
            end
        end
    end
end

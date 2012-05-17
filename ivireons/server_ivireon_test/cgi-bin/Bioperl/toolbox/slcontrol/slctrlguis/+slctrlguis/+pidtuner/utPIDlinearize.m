function G = utPIDlinearize(blkh, op)
% PID helper function

% This function linearize Simulink model to obtain a LTI plant seen by PID
% blocks
%   blkh: pid block handle
%   op: empty - default operating point 
%       @op object - existing operating point 
%       double - snap time 
%   G:  state space plant model

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2010/03/31 18:59:15 $

%% get model information
model = get_param(bdroot(blkh),'Name');
%% create linearization input point
input_blk = getfullname(blkh);
input_point = linio(input_blk,1,'in','on');
%% create linearization output point
output_port = find_system(blkh,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','Inport');
if strcmp(get(blkh,'MaskType'),'PID 1dof')
    output_blk = getfullname(output_port(1));
    output_point = linio(output_blk,1,'out','on');
    io = [input_point; output_point];
    for ct=1:length(output_port)-1
        output_blk = getfullname(output_port(ct+1));
        output_point = linio(output_blk,1,'none','on');
        io = [io; output_point]; %#ok<*AGROW>
    end
else
    output_blk_r = getfullname(output_port(1));
    output_blk_y = getfullname(output_port(2));
    output_point_r = linio(output_blk_r,1,'none','on');
    output_point_y = linio(output_blk_y,1,'out','on');
    io = [input_point; output_point_y; output_point_r];
    for ct=1:length(output_port)-2
        output_blk = getfullname(output_port(ct+2));
        output_point = linio(output_blk,1,'none','on');
        io = [io; output_point];
    end
end
%% linearize model using exact delay
options = linoptions('UseExactDelayModel','on');
if isempty(op)
    G = linearize(model,io,options);
else
    G = linearize(model,op,io,options);
end
%% always assume negative feedback loop
if strcmp(get(blkh,'MaskType'),'PID 1dof')
    G = -G;
end
%% check whether model is valid
% error out when plant model is empty
if isempty(G)
    ctrlMsgUtils.error('Slcontrol:pidtuner:tunerdlg_planterror');
end
% error out when plant model is not siso
if ~issiso(G)
    ctrlMsgUtils.error('Slcontrol:pidtuner:tunerdlg_sisoerror');
end
% error out when plant is effectively gain block
if dcgain(G)==0
    ctrlMsgUtils.error('Slcontrol:pidtuner:tunerdlg_planterror');
end
% error out when Ts is -1
if getTs(G)<0
    ctrlMsgUtils.error('Slcontrol:pidtuner:tunerdlg_tserror');
end

function addPorts(currentblock)

% ADDPORTS  Add/Remove the appropriate ports for the PID 1dof and PID 2dof
% blocks. This routine will also only set the position, port number, and
% Name of each of the ports.

%   Author: Murad Abu-Khalaf, October 12, 2009
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/01/25 22:57:46 $

blkH = handle(currentblock);
blk = getfullname(currentblock);

if strcmp(blkH.MaskType,'PID 1dof')
    posU =      [25   115    45   135];
    posY =      [610   115   630   135];
    posReset =  [35   375    55   395];
    posI0  =    [35   440    55   460];
    posD0 =     [35   495    55   515];
    posTR =     [35   545    55   565];
    offset = 0;
elseif strcmp(blkH.MaskType,'PID 2dof')
    posR =      [15    95    35   115];
    posU =      [745   115   765   135];
    posY =      [15   135    35   155];
    posReset =  [15   375    35   395];
    posI0  =    [15   440    35   460];
    posD0 =     [15   495    35   515];
    posTR =     [15   545    35   565];
    set_param([blk '/r'],'Position',posR);
    offset = 1;
else
    error('Unknown MaskType');
end

set_param([blk '/u'],'Position',posU);
set_param([blk '/y'],'Position',posY);


isRESET = find_system(blk,'SearchDepth',1,'FollowLinks','on',...
    'LookUnderMasks','all','Name','RESET');
isI0 = find_system(blk,'SearchDepth',1,'FollowLinks','on',...
    'LookUnderMasks','all','Name','I0');
isD0 = find_system(blk,'SearchDepth',1,'FollowLinks','on',...
    'LookUnderMasks','all','Name','D0');
isTrackingmode = find_system(blk,'SearchDepth',1,'FollowLinks','on',...
    'LookUnderMasks','all','Name','TR');

if strcmp(blkH.ExternalReset,'none')
    pidpack.PIDConfig.delete_block_lines(isRESET);
else
    if ~strcmp(blkH.Controller,'P')
        if isempty(isRESET)
            add_block('built-in/Inport',[blk '/RESET'],'Position',posReset);
        end
        set_param([blk '/RESET'],'Port',num2str(2+offset));
    end
end

if strcmp(blkH.Controller,'PID')
    if strcmp(blkH.InitialConditionSource,'internal')
        pidpack.PIDConfig.delete_block_lines(isI0);
        pidpack.PIDConfig.delete_block_lines(isD0);
    else
        if isempty(isI0)
            add_block('built-in/Inport',[blk '/I0'],'Position',posI0);
        end
        if isempty(isD0)
            add_block('built-in/Inport',[blk '/D0'],'Position',posD0);
        end
        if strcmp(blkH.ExternalReset,'none')
            set_param([blk '/I0'],'Port',num2str(2+offset));
            set_param([blk '/D0'],'Port',num2str(3+offset));
        else
            set_param([blk '/I0'],'Port',num2str(3+offset));
            set_param([blk '/D0'],'Port',num2str(4+offset));
        end
    end
elseif strcmp(blkH.Controller,'PI') || strcmp(blkH.Controller,'I')
    if strcmp(blkH.InitialConditionSource,'internal')
        pidpack.PIDConfig.delete_block_lines(isI0);
    else
        pidpack.PIDConfig.delete_block_lines(isD0);
        if isempty(isI0)
            add_block('built-in/Inport',[blk '/I0'],'Position',posI0);
        end
        if strcmp(blkH.ExternalReset,'none')
            set_param([blk '/I0'],'Port',num2str(2+offset));
        else
            set_param([blk '/I0'],'Port',num2str(3+offset));
        end
    end
elseif strcmp(blkH.Controller,'PD')
    pidpack.PIDConfig.delete_block_lines(isTrackingmode);
    if strcmp(blkH.InitialConditionSource,'internal')
        pidpack.PIDConfig.delete_block_lines(isD0);
    else
        pidpack.PIDConfig.delete_block_lines(isI0);
        if isempty(isD0)
            add_block('built-in/Inport',[blk '/D0'],'Position',posD0);
        end
        if strcmp(blkH.ExternalReset,'none')
            set_param([blk '/D0'],'Port',num2str(2+offset));
        else
            set_param([blk '/D0'],'Port',num2str(3+offset));
        end
    end
elseif strcmp(blkH.Controller,'P')
    pidpack.PIDConfig.delete_block_lines(isTrackingmode);
    pidpack.PIDConfig.delete_block_lines(isRESET);
    pidpack.PIDConfig.delete_block_lines(isI0);
    pidpack.PIDConfig.delete_block_lines(isD0);
end

if strcmp(blkH.TrackingMode,'off')
    pidpack.PIDConfig.delete_block_lines(isTrackingmode);
else
    if ~(strcmp(blkH.Controller,'P') || strcmp(blkH.Controller,'PD'))
        if isempty(isTrackingmode)
            add_block('built-in/Inport',[blk '/TR'],'Position',posTR);
        end
    end
end

end
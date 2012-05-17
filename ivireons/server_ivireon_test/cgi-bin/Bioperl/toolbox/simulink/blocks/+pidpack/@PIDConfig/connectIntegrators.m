function connectIntegrators(currentblock)

% CONNECTINTEGRATORS Connect Integrators to RESET and I0 and D0 ports

%   Author: Murad Abu-Khalaf, October 12, 2009
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/01/25 22:57:55 $

blk = getfullname(currentblock);
blkH = handle(currentblock);

isIntegrator = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Integrator');
isFilter = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Filter');
isRESET = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','RESET');
isI0 = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','I0');
isD0 = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','D0');

if ~isempty(isIntegrator)
    if ~isempty(isRESET) && ~strcmp(blkH.ExternalReset,'none')
        add_line(blk,'RESET/1','Integrator/2','autorouting','on')
    end
    inports = get_param([blk  '/Integrator'],'Ports');
    if ~isempty(isI0) % Check for errors by verifying that strcmp(InitialConditionSource,'external')
        add_line(blk,'I0/1',['Integrator/' num2str(inports(1))],'autorouting','on');
    end
end
if ~isempty(isFilter)
    if ~isempty(isRESET) && ~strcmp(blkH.ExternalReset,'none')
        add_line(blk,'RESET/1','Filter/2','autorouting','on')
    end
    inports = get_param([blk  '/Filter'],'Ports');
    if ~isempty(isD0) % Check for errors by verifying that strcmp(InitialConditionSource,'external')
        add_line(blk,'D0/1',['Filter/' num2str(inports(1))],'autorouting','on')
    end
end

end
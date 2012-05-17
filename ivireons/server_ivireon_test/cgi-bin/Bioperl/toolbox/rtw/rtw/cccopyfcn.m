function cccopyfcn(block)
%CCCOPYFCN Custom Code blocks Copyfcn callback


%   Copyright 1994-2006 The MathWorks, Inc.
%   $Revision: 1.8.2.1 $

%
% Abstract:
%   cccodefcn deletes empty subsystems in Custom Code blocks
%   required for Simulink Library Browser functionality
%

%break library link
link_status = get_param(block, 'LinkStatus');
if strcmp(link_status, 'resolved') || strcmp(link_status, 'inactive')
    set_param(block, 'LinkStatus', 'none');
end

%delete empty subsystem
asub=find_system(block,'LookUnderMasks','all','BlockType','SubSystem');
if ~isempty(asub) & (length(asub) > 1)
  delete_block(asub{2});
end



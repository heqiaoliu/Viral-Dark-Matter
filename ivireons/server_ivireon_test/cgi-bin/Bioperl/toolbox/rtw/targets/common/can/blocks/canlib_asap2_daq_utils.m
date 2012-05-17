function varargout = canlib_asap2_daq_utils(util,varargin)
% private utilities used for CCP DAQ list implementation

%   Copyright 2002-2009 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $

switch lower(util)
    case 'normalbuild'
        varargout{1} = internal_normal_build;
    case 'originalhandle'
        varargout{1} = internal_original_handle;
    case 'totalnumodts'
        sourceSystem = varargin{1};
        varargout{1} = internal_total_num_odts(sourceSystem);
end

function total_num_odts = internal_total_num_odts(sourceSystem)
    % search for canblocks_extras/CAN Calibration Protocol block which is
    % shared by all CCP implementations (C166, MPC555, C2000)
    coreCCPBlock = find_system(sourceSystem, ...
                      'FollowLinks', 'on', ...
                      'LookUnderMasks', 'on', ...
                      'ReferenceBlock', 'canblocks_extras/CAN Calibration Protocol');
    % single instance of CCP block is enforced elsewhere
    assert(length(coreCCPBlock) == 1, ...
           'Multiple instances of the CCP block are not allowed.');    
    coreCCPBlock = coreCCPBlock{1};
    
    % resolve the TOTAL_NUM_ODTS variable in the context of the
    % coreCCPBlock
    total_num_odts = slResolve('TOTAL_NUM_ODTS', coreCCPBlock);   

function original_handle = internal_original_handle
    % get the original block handle - use this when we are 
    % right click building
    % rtwattic is a private function
    original_handle = rtwprivate('rtwattic','AtticData', 'OrigBlockHdl');

function normal_build = internal_normal_build 
% Right Click build UI invokes ssgencode, so we can check that arriving
% here came through ssgencode by looking at the execution stack.
normal_build = 1;
Context = dbstack;
for i = 1:length(Context)
    if strfind(Context(i).name,'ssgencode')
        normal_build = 0;
        return;
    end
end

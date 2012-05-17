function D = utCheckComputability(D,ResponseType,varargin)
% Checks if requested system response is computable.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:00 $

if strncmp(ResponseType,{'rlocus'},2)
    ctrlMsgUtils.error('Control:general:NotSupportedRootLocusModelsofClass','frd')
elseif any(strncmp(ResponseType,{'iopzmap', 'pzmap'},2))
    ctrlMsgUtils.error('Control:general:NotSupportedPoleZeroModelsofClass','frd')  
elseif any(strncmp(ResponseType,{'impulse','initial','lsim','step' },2))
    ctrlMsgUtils.error('Control:general:NotSupportedSimulationModelsOfClass','frd')
elseif ~any(strncmp(ResponseType,{'bode','bodemag','nyquist','nichols','sigma'},2))
    ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass2','frd')
end


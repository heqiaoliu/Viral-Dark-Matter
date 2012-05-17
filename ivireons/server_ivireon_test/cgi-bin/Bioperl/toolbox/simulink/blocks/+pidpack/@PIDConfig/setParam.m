function setParam(currentblock)

% SETPARAM  Modify the parameters of the blocks under mask for PID 1dof and
% PID 2dof blocks.

%   Author: Murad Abu-Khalaf, October 12, 2009
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/01/25 22:58:01 $

blkH = handle(currentblock);
blk = getfullname(currentblock);

isSum         = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Sum');
isSum1        = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Sum1');
isSum2        = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Sum2');
isSum3        = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Sum3');
isSumD        = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','SumD');
isSumI1       = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','SumI1');
isSumI2       = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','SumI2');
isSumI3       = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','SumI3');
isP           = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Proportional Gain');
isI           = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Integral Gain');
isD           = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Derivative Gain');
isN           = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Filter Coefficient');
isKb          = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Kb');
isKt          = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Kt');
isb           = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name',sprintf('Setpoint Weighting\n(Proportional)'));
isc           = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name',sprintf('Setpoint Weighting\n(Derivative)'));
isIntegrator  = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Integrator');
isFilter      = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Filter');
isSat         = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Saturation');
isSwitch      = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Switch');
isConstant    = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Constant');
isRESET       = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','RESET');
isI0          = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','I0');
isD0          = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','D0');
isTrackingmode = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','TR');

%% Configure Input ports
if strcmp(blkH.TimeDomain,'Continuous-time')
    commonInPorts = {'SampleTime','-1'};
else
    commonInPorts = {'SampleTime','SampleTime'};
end

if strcmp(blkH.MaskType,'PID 1dof')
    set_param([blk '/u'],commonInPorts{:});
    outStr = 'y';
elseif strcmp(blkH.MaskType,'PID 2dof')
    set_param([blk '/r'],commonInPorts{:});
    set_param([blk '/y'],commonInPorts{:});
    outStr = 'u';
else
    error('Unknown MaskType');
end

if ~isempty(isRESET)
    set_param([blk '/RESET'],commonInPorts{:});
end
if ~isempty(isI0)
    set_param([blk '/I0'],commonInPorts{:});
end
if ~isempty(isD0)
    set_param([blk '/D0'],commonInPorts{:});
end
if ~isempty(isTrackingmode)
    set_param([blk '/TR'],commonInPorts{:});
end


%% Configure summation blocks first.
% This must be first so that the "Require all inputs to have the same data
% type" be turned off
commonSum = {'InputSameDT', 'off','LockScale',blkH.LockScale,'RndMeth',blkH.RndMeth,...
    'SaturateOnIntegerOverflow',blkH.SaturateOnIntegerOverflow,'SampleTime','-1','DisableCoverage','on'};
if ~isempty(isSum)
    set_param([blk '/Sum'], 'AccumDataTypeStr','SumAccumDataTypeStr',...
        'OutMin','SumOutMin','OutMax','SumOutMax','OutDataTypeStr','SumOutDataTypeStr',commonSum{:});
end
if ~isempty(isSum1)
    set_param([blk '/Sum1'],'AccumDataTypeStr','Sum1AccumDataTypeStr',...
        'OutMin','Sum1OutMin','OutMax','Sum1OutMax','OutDataTypeStr','Sum1OutDataTypeStr',commonSum{:});
end
if ~isempty(isSum2)
    set_param([blk '/Sum2'],'AccumDataTypeStr','Sum2AccumDataTypeStr',...
        'OutMin','Sum2OutMin','OutMax','Sum2OutMax','OutDataTypeStr','Sum2OutDataTypeStr',commonSum{:});
end
if ~isempty(isSum3)
    set_param([blk '/Sum3'],'AccumDataTypeStr','Sum3AccumDataTypeStr',...
        'OutMin','Sum3OutMin','OutMax','Sum3OutMax','OutDataTypeStr','Sum3OutDataTypeStr',commonSum{:});
end
if ~isempty(isSumD)
    set_param([blk '/SumD'], 'AccumDataTypeStr','SumDAccumDataTypeStr',...
        'OutMin','SumDOutMin','OutMax','SumDOutMax','OutDataTypeStr','SumDOutDataTypeStr',commonSum{:});
end
if ~isempty(isSumI1)
    set_param([blk '/SumI1'],'AccumDataTypeStr','SumI1AccumDataTypeStr',...
        'OutMin','SumI1OutMin','OutMax','SumI1OutMax','OutDataTypeStr','SumI1OutDataTypeStr',commonSum{:});
end
if ~isempty(isSumI2)
    set_param([blk '/SumI2'],'AccumDataTypeStr','SumI2AccumDataTypeStr',...
        'OutMin','SumI2OutMin','OutMax','SumI2OutMax','OutDataTypeStr','SumI2OutDataTypeStr',commonSum{:});
end
if ~isempty(isSumI3)
    set_param([blk '/SumI3'],'AccumDataTypeStr','SumI3AccumDataTypeStr',...
        'OutMin','SumI3OutMin','OutMax','SumI3OutMax','OutDataTypeStr','SumI3OutDataTypeStr',commonSum{:});
end

%% Configure all gain blocks
commonGain = {'Multiplication','Element-wise(K.*u)','LockScale',blkH.LockScale,'RndMeth',blkH.RndMeth,...
    'SaturateOnIntegerOverflow',blkH.SaturateOnIntegerOverflow,'SampleTime','-1','DisableCoverage','on'};

if ~isempty(isP)
    set_param([blk '/Proportional Gain'], 'Gain', 'P','ParamMin','PParamMin','ParamMax','PParamMax',...
        'ParamDataTypeStr','PParamDataTypeStr','OutMin','POutMin','OutMax','POutMax',...
        'OutDataTypeStr','POutDataTypeStr',commonGain{:});
end
if ~isempty(isI)
    set_param([blk '/Integral Gain'], 'Gain', 'I','ParamMin','IParamMin','ParamMax','IParamMax',...
        'ParamDataTypeStr','IParamDataTypeStr','OutMin','IOutMin','OutMax','IOutMax',...
        'OutDataTypeStr','IOutDataTypeStr',commonGain{:});
end
if ~isempty(isD)
    set_param([blk '/Derivative Gain'], 'Gain', 'D','ParamMin','DParamMin','ParamMax','DParamMax',...
        'ParamDataTypeStr','DParamDataTypeStr','OutMin','DOutMin','OutMax','DOutMax',...
        'OutDataTypeStr','DOutDataTypeStr',commonGain{:});
end
if ~isempty(isN)
    set_param([blk '/Filter Coefficient'], 'Gain', 'N','ParamMin','NParamMin','ParamMax','NParamMax',...
        'ParamDataTypeStr','NParamDataTypeStr','OutMin','NOutMin','OutMax','NOutMax',...
        'OutDataTypeStr','NOutDataTypeStr',commonGain{:});
end
if ~isempty(isKb)
    set_param([blk '/Kb'], 'Gain', 'Kb','ParamMin','KbParamMin','ParamMax','KbParamMax',...
        'ParamDataTypeStr','KbParamDataTypeStr','OutMin','KbOutMin','OutMax','KbOutMax',...
        'OutDataTypeStr','KbOutDataTypeStr',commonGain{:});
end
if ~isempty(isKt)
    set_param([blk '/Kt'], 'Gain', 'Kt','ParamMin','KtParamMin','ParamMax','KtParamMax',...
        'ParamDataTypeStr','KtParamDataTypeStr','OutMin','KtOutMin','OutMax','KtOutMax',...
        'OutDataTypeStr','KtOutDataTypeStr',commonGain{:});
end
if ~isempty(isb)    
    set_param([blk sprintf('/Setpoint Weighting\n(Proportional)')], 'Gain', 'b',...
        'ParamMin','bParamMin','ParamMax','bParamMax',...
        'ParamDataTypeStr','bParamDataTypeStr','OutMin','bOutMin','OutMax','bOutMax',...
        'OutDataTypeStr','bOutDataTypeStr',commonGain{:});
end
if ~isempty(isc)
    set_param([blk sprintf('/Setpoint Weighting\n(Derivative)')], 'Gain', 'c',...
        'ParamMin','cParamMin','ParamMax','cParamMax',...
        'ParamDataTypeStr','cParamDataTypeStr','OutMin','cOutMin','OutMax','cOutMax',...
        'OutDataTypeStr','cOutDataTypeStr',commonGain{:});
end

%% Configure all integrator blocks
if ~isempty(isIntegrator)
    if strcmp(get_param([blk '/Integrator'],'BlockType'),'Integrator')
        set_param([blk '/Integrator'], 'InitialCondition','InitialConditionForIntegrator','LimitOutput','off',...
            'UpperSaturationLimit','inf','LowerSaturationLimit','-inf','ShowSaturationPort','off',...
            'ShowStatePort','off','AbsoluteTolerance','auto','IgnoreLimit',blkH.IgnoreLimit,...
            'ZeroCross',blkH.ZeroCross,'ContinuousStateAttributes',blkH.IntegratorContinuousStateAttributes,'DisableCoverage','on');
    else
        set_param([blk '/Integrator'],'IntegratorMethod',blkH.IntegratorMethod, 'gainval','1.0',...
            'InitialCondition','InitialConditionForIntegrator','InitialConditionMode','State only (most efficient)',...
            'SampleTime','-1','OutMin','IntegratorOutMin','OutMax','IntegratorOutMax','OutDataTypeStr','IntegratorOutDataTypeStr',...
            'LockScale',blkH.LockScale,'RndMeth',blkH.RndMeth,'SaturateOnIntegerOverflow',blkH.SaturateOnIntegerOverflow,...
            'LimitOutput','off','UpperSaturationLimit','inf','LowerSaturationLimit','-inf','ShowSaturationPort','off',...
            'ShowStatePort','off','IgnoreLimit',blkH.IgnoreLimit,...
            'StateIdentifier',blkH.IntegratorStateIdentifier,'StateMustResolveToSignalObject',blkH.IntegratorStateMustResolveToSignalObject,...
            'RTWStateStorageClass',blkH.IntegratorRTWStateStorageClass,...
            'RTWStateStorageTypeQualifier',blkH.IntegratorRTWStateStorageTypeQualifier,'DisableCoverage','on');
    end
end
if ~isempty(isFilter)
    if strcmp(get_param([blk '/Filter'],'BlockType'),'Integrator')
        set_param([blk '/Filter'], 'InitialCondition','InitialConditionForFilter','LimitOutput','off',...
            'UpperSaturationLimit','inf','LowerSaturationLimit','-inf','ShowSaturationPort','off',...
            'ShowStatePort','off','AbsoluteTolerance','auto','IgnoreLimit',blkH.IgnoreLimit,...
            'ZeroCross',blkH.ZeroCross,'ContinuousStateAttributes',blkH.FilterContinuousStateAttributes,'DisableCoverage','on');
    else
        set_param([blk '/Filter'],'IntegratorMethod',blkH.FilterMethod, 'gainval','1.0',...
            'InitialCondition','InitialConditionForFilter','InitialConditionMode','State only (most efficient)',...
            'SampleTime','-1','OutMin','FilterOutMin','OutMax','FilterOutMax','OutDataTypeStr','FilterOutDataTypeStr',...
            'LockScale',blkH.LockScale,'RndMeth',blkH.RndMeth,'SaturateOnIntegerOverflow',blkH.SaturateOnIntegerOverflow,...
            'LimitOutput','off','UpperSaturationLimit','inf','LowerSaturationLimit','-inf','ShowSaturationPort','off',...
            'ShowStatePort','off','IgnoreLimit',blkH.IgnoreLimit,...
            'StateIdentifier',blkH.FilterStateIdentifier,'StateMustResolveToSignalObject',blkH.FilterStateMustResolveToSignalObject,...
            'RTWStateStorageClass',blkH.FilterRTWStateStorageClass,...
            'RTWStateStorageTypeQualifier',blkH.FilterRTWStateStorageTypeQualifier,'DisableCoverage','on');
    end
end

%% Configure saturation block settings
if ~isempty(isSat)
    set_param([blk '/Saturation'], 'UpperLimit', 'UpperSaturationLimit',...
        'LowerLimit','LowerSaturationLimit','LinearizeAsGain',blkH.LinearizeAsGain,...
        'ZeroCross',blkH.ZeroCross,'SampleTime','-1','OutMin','SaturationOutMin','OutMax','SaturationOutMax',...
        'OutDataTypeStr','SaturationOutDataTypeStr','LockScale',blkH.LockScale,'RndMeth',blkH.RndMeth,...
        'DisableCoverage','on');
end

%% Configure Switch block
if ~isempty(isSwitch)
    set_param([blk '/Switch'], 'Criteria','u2 > Threshold','Threshold','0','InputSameDT','on',...
        'OutMin','[]','OutMax','[]','OutDataTypeStr','Inherit: Inherit via internal rule',...
        'LockScale',blkH.LockScale,'RndMeth',blkH.RndMeth,'SaturateOnIntegerOverflow',blkH.SaturateOnIntegerOverflow,...
        'ZeroCross',blkH.ZeroCross,'SampleTime','-1','DisableCoverage','on');
end

%% Configure Constant block
if ~isempty(isConstant)
    set_param([blk '/Constant'], 'Value','0','OutMin','[]','OutMax','[]',...
        'OutDataTypeStr','Inherit: Inherit via back propagation',...
        'LockScale',blkH.LockScale,'SampleTime','inf','preserveConstantTs','on',...
        'DisableCoverage','on'); % preserveConstantTs (g592069)
end


% Code coverage:
% The basic idea is that you should disable coverage recording for all the
% block underneath a Simulink.mdl mask *except* for blocks that directly
% feed a mask output. The reason to do this is that the we want to avoid
% showing signal range coverage for the contents of a "core" masked
% subsystem that are not related to a users design but we want to show
% range coverage for the mask itself so we need to instrument the blocks
% that feed the outputs.
h = handle(get_param([blk '/' outStr],'handle'));
Src = h.PortConnectivity(1).SrcBlock;
Src = handle(Src);
Src.DisableCoverage = 'off';

end
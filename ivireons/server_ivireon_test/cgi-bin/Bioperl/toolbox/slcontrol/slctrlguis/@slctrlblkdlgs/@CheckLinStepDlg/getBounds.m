function bnds = getBounds(hBlk)

% Author(s): A. Stothert
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:29 $

% GETBOUNDS static method to return requirement object(s) described by
% the Linear Step Response check block
%

blk = getFullName(hBlk);

%Construct step response requirement from the block data
stepChar.StepTime     = 0;
stepChar.InitialValue = 0;
try
   stepChar.FinalValue  = slResolve(hBlk.FinalValue,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar',...
      'FinalValue',blk);
end
try   
   stepChar.RiseTime  = slResolve(hBlk.RiseTime,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar',...
      'RiseTime',blk);
end
try   
   stepChar.PercentRise  = slResolve(hBlk.PercentRise,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPercent',...
      'PercentRise',blk);
end
try   
   stepChar.SettlingTime  = slResolve(hBlk.SettlingTime,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar',...
      'SettlingTime',blk);
end
try   
   stepChar.PercentSettling  = slResolve(hBlk.PercentSettling,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPercent',...
      'PercentSettling',blk);
end
try   
   stepChar.PercentOvershoot  = slResolve(hBlk.PercentOvershoot,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPercent',...
      'PercentOvershoot',blk);
end
try   
   stepChar.PercentUndershoot  = slResolve(hBlk.PercentUndershoot,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPercent',...
      'PercentUndershoot',blk);
end

%Check that the step characteristics are consistent
if stepChar.RiseTime >= stepChar.SettlingTime
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errLinStepRiseTime',blk);
end
if stepChar.PercentSettling > stepChar.PercentOvershoot
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errLinStepPercentSettling',blk)
end
if stepChar.PercentRise > 100-stepChar.PercentSettling
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errLinStepPercentRise',blk);
end

%Could get this far with an empty requirement so check if we really are
%empty
emptyStep = isempty(stepChar.FinalValue) || ...
   isempty(stepChar.RiseTime) || isempty(stepChar.PercentRise) || ...
   isempty(stepChar.SettlingTime) || isempty(stepChar.PercentSettling) || ...
   isempty(stepChar.PercentOvershoot) || ...
   isempty(stepChar.PercentUndershoot);
if emptyStep
   bnds = {};
else
   %Construct the requirement
   hReq = srorequirement.stepresponse;
   hReq.isEnabled = strcmp(hBlk.EnableStepResponseBound,'on');
   ok = hReq.setStepCharacteristics(stepChar);
   if ok
      bnds = {hReq};
   else
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errLinStepUnexpected',blk);
   end
end
end


function ok = setBounds(hBlk,hC,varargin)
%

% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.4.2.1 $ $Date: 2010/06/21 18:06:55 $

% SETBOUNDS static method to set block bound parameters given a vector of
% requirement objects. The method is called by the block visualization.
%

if nargin > 2
   %Update block parameters without prompting for user input
   silentFlag = true;
else
   silentFlag = false;
end

%Check whether the passed requirement is being displayed (and hence has
%display units) or not. This is needed for unit conversion as block data is
%always represented in displayed units but the requirement object may be 
%using different units.
if isa(hC,'plotconstr.designconstr') || isa(hC,'editconstr.absInteractiveConstr')
   hReq = hC.getRequirementObject;
else
   hReq = hC;
end

if ~isa(hReq,'srorequirement.stepresponse') && ~isempty(hReq)
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errInvalidReqType',getFullName(hBlk), ...
      'srorequirement.stepresponse',class(hReq))
end
if numel(hReq) > 1
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockLimitedToOneReq',getFullName(hBlk),'srorequirement.stepresponse');
end

%Serialize the upper and lower bound data
[strVals,props] = localSerialize(hReq);

%Push the data to block properties
blk = getFullName(hBlk);
ok = localUpdateBlockParameter(hBlk,blk, ...
   props, strVals, silentFlag, ...
   'Slcontrol:slctrlblkdlgs:txtUpdateBound');
end

function [strVals, props] = localSerialize(hReq)
% Helper function to serialize requirement data to write to a block
% parameter

props = {...
   'FinalValue', ...
   'RiseTime', ...
   'PercentRise', ...
   'SettlingTime', ...
   'PercentSettling', ...
   'PercentOvershoot', ...
   'PercentUndershoot'};

nReq = numel(hReq);
if nReq == 0
   strVals = cell(size(props));
   strVals(:) = {'[]'};
   return
end

%Single bound, create a string for an array with bound data
data = hReq.getStepCharacteristics;
strFinalValue        = mat2str(data.FinalValue);
strRiseTime          = mat2str(data.RiseTime);
strPercentRise       = mat2str(data.PercentRise);
strSettlingTime      = mat2str(data.SettlingTime);
strPercentSettling   = mat2str(data.PercentSettling);
strPercentOvershoot  = mat2str(data.PercentOvershoot);
strPercentUndershoot = mat2str(data.PercentUndershoot);
strVals = {...
   strFinalValue, ...
   strRiseTime, ...
   strPercentRise, ...
   strSettlingTime, ...
   strPercentSettling, ...
   strPercentOvershoot, ...
   strPercentUndershoot};
end

function ok = localUpdateBlockParameter(hBlk,blk,params,strVal,silent,msgId)
%Helper function to update block parameter

%Have the parameter values changed?
nP      = numel(params);
allSame = true;
ct      = 1;
while allSame && ct <= nP
   val = slResolve(hBlk.(params{ct}),blk);
   allSame = allSame && isequal(val,eval(strVal{ct}));
   ct = ct + 1;
end
if allSame, ok = true; return, end

opts = struct(...
   'ShowWarningDlg', ~silent, ...
   'WarningMsgIDNoVar', msgId, ...
   'WarningMsgIDWithVar', strcat(msgId,'Variable'), ...
   'WarningTitleID', 'Slcontrol:slctrlblkdlgs:txtTitleBoundUpdate');
ok = slctrlguis.updateBlockParameter(blk,params,strVal,opts);
end
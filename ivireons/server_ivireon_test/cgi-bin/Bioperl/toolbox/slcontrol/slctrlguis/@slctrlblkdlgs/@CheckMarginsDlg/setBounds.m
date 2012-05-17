function ok = setBounds(hBlk,hC,varargin)
%

% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.4.2.1 $ $Date: 2010/06/21 18:06:56 $

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
   haveDisplayedReq = true;
else
   hReq = hC;
   haveDisplayedReq = false;
end

%Separate requirements into supported types
if ~isa(hReq,'srorequirement.gainphasemargin')  && ~isempty(hReq)
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errInvalidReqType',getFullName(hBlk), ...
      'srorequirement.gainphasemargin',class(hReq))
end
if numel(hReq) > 1
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockLimitedToOneReq',getFullName(hBlk),'srorequirement.gainpahsemargin');
end

if haveDisplayedReq
   DisplayUnits = struct(...
      'Magnitude', hC.getDisplayUnits('yunits'), ...
      'Phase', hC.getDisplayUnits('xunits'));
else
   DisplayUnits = struct(...
      'Magnitude', hBlk.MagnitudeUnits, ...
      'Phase',     hBlk.PhaseUnits);
end

%Serialize the margin bounds
[strGM,strPM] = localSerializeGPM(hReq,DisplayUnits);

%Push the data to block properties
blk = getFullName(hBlk);
ok = localUpdateBlockParameter(hBlk,blk, {'GainMargin','PhaseMargin'}, {strGM, strPM}, silentFlag, ...
   'Slcontrol:slctrlblkdlgs:txtUpdateBound');

if ok
   %Bound data was successfully updated, update block units
   hBlk.MagnitudeUnits = DisplayUnits.Magnitude;
   hBlk.PhaseUnits     = DisplayUnits.Phase;
   
   %Update the block feedback sign property
   if hReq.FeedbackSign == 1;
      hBlk.FeedbackSign = '+1';
   else
      hBlk.FeedbackSign = '-1';
   end
end
end

function [strGM, strPM] = localSerializeGPM(hReq,DisplayUnits)
% Helper function to serialize requirement data to write to a block
% parameter

nReq = numel(hReq);
if nReq == 0
   strGM = '[]';
   strPM = '[]';
   return
end

if nReq > 1
   %Multiple bounds, create a string for a cell array with bound data
   strGM = '{ ';
   strPM = '{ ';
   for ct = 1:nReq-1
      [xdata,ydata] = localGetGPMData(hReq(ct),DisplayUnits);
      strPM = sprintf('%s%s, ', strPM, mat2str(xdata));
      strGM = sprintf('%s%s, ', strGM, mat2str(ydata));
   end
   [xdata,ydata] = localGetGPMData(hReq(nReq),DisplayUnits);
   strPM = sprintf('%s%s}', strPM, mat2str(xdata));
   strGM = sprintf('%s%s}', strGM, mat2str(ydata));
else
   %Single bound, create a string for an array with bound data
   [xdata,ydata] = localGetGPMData(hReq,DisplayUnits);
   strGM = mat2str(ydata);
   strPM = mat2str(xdata);
end
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

function [xdata,ydata] = localGetGPMData(hReq,DisplayUnits)
%Helper function to return data to push to block parameters

switch hReq.getData('type')
   case 'gain'
      xdata = [];
      ydata = hReq.getData('yData');
   case 'phase'
      xdata = hReq.getData('xData');
      ydata = [];
   case 'both'
      xdata = hReq.getData('xData');
      ydata = hReq.getData('yData');
end
xdata = unitconv(xdata,hReq.getData('xunits'),DisplayUnits.Phase);
ydata = unitconv(ydata,hReq.getData('yunits'),DisplayUnits.Magnitude);
end


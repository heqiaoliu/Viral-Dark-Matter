function ok = setBounds(hBlk,hC,varargin)
%

% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.4.2.1 $ $Date: 2010/06/21 18:06:57 $

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
hGPM    = [];
hCLPeak = [];
hGPLoc  = [];
for ct=1:numel(hReq)
   if isa(hReq(ct),'srorequirement.gainphasemargin') 
      hGPM = vertcat(hGPM,hReq(ct)); %#ok<AGROW>
   end
   if isa(hReq(ct),'srorequirement.nicholspeak')
      hCLPeak = vertcat(hCLPeak,hReq(ct)); %#ok<AGROW>
   end
   if isa(hReq(ct),'srorequirement.nicholslocation')
      hGPLoc = vertcat(hGPLoc,hReq(ct)); %#ok<AGROW>
   end
end
if isempty(hGPM) && isempty(hCLPeak) && isempty(hGPLoc) && ~isempty(hReq)
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errInvalidReqType',getFullName(hBlk), ...
      'srorequirement.gainphasemargin, srorequirement.nicholspeak, srorequirement.nicholslocation',class(hReq))
end

if haveDisplayedReq
   DisplayUnits = struct(...
      'Magnitude', hC(1).getDisplayUnits('yunits'), ...
      'Phase', hC(1).getDisplayUnits('xunits'));
else
   DisplayUnits = struct(...
      'Magnitude', hBlk.MagnitudeUnits, ...
      'Phase',     hBlk.PhaseUnits);
end

%Serialize the margin bounds
[strGM,strPM] = localSerializeGPM(hGPM,DisplayUnits);
%Serialize Closed-loop peak gain bounds
strCLPeak = localSerializeCLPeak(hCLPeak,DisplayUnits);
%Serialize the gain-phase location bounds
[strOLPhases,strOLGains,strGPBType] = localSerializeGPLoc(hGPLoc,DisplayUnits);
   
%Push the data to block properties
blk = getFullName(hBlk);
ok = localUpdateBlockParameter(hBlk,blk, ...
   {'GainMargin','PhaseMargin','CLPeakGain', 'OLPhases', 'OLGains', 'GainPhaseBoundType'}, ...
   {strGM, strPM, strCLPeak, strOLPhases, strOLGains, strGPBType}, ...
   silentFlag, ...
   'Slcontrol:slctrlblkdlgs:txtUpdateBound');

if ok
   %Bound data was successfully updated, update block units
   hBlk.MagnitudeUnits = DisplayUnits.Magnitude;
   hBlk.PhaseUnits     = DisplayUnits.Phase;
   
   %Update the block feedback sign property, could have multiple bounds
   %with different feedback signs but block only has one feedback sign so
   %use first passed requirement
   if hReq(1).FeedbackSign == 1;
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

function strVal = localSerializeCLPeak(hReq,DisplayUnits)
% Helper function to serialize requirement data to write to a block
% parameter

nReq = numel(hReq);
if nReq == 0
   strVal = '[]';
   return
end

if nReq > 1
   %Multiple bounds, create a string for a cell array with bound data
   strVal = '{ ';
   for ct = 1:nReq-1
      data = hReq(ct).getData('yData');
      data = unitconv(data,hReq(ct).getData('yunits'),DisplayUnits.Magnitude);
      strVal = sprintf('%s%s, ', strVal, mat2str(data));
   end
   data = hReq(nReq).getData('yData');
   data = unitconv(data,hReq(nReq).getData('yunits'),DisplayUnits.Magnitude);
   strVal = sprintf('%s%s}', strVal, mat2str(data));
else
   %Single bound, create a string for an array with bound data
   data = hReq.getData('yData');
   data = unitconv(data,hReq.getData('yunits'),DisplayUnits.Magnitude);
   strVal = mat2str(data);
end
end

function [strOLPhases,strOLGains,strGPBType] = localSerializeGPLoc(hReq,DisplayUnits)
% Helper function to serialize requirement data to write to a block
% parameter

nReq = numel(hReq);
if nReq == 0
   strOLPhases = '[]';
   strOLGains  = '[]';
   strGPBType  = '{''upper''}';
   return
end

if nReq > 1
   strOLPhases = '{ ';
   strOLGains  = '{ ';
   strGPBType  = '{ ';
   for ct = 1:nReq-1
      xdata = hReq(ct).getData('xData');
      xdata = unitconv(xdata,hReq(ct).getData('xunits'),DisplayUnits.Phase);
      ydata = hReq(ct).getData('yData');
      ydata = unitconv(ydata,hReq(ct).getData('yunits'),DisplayUnits.Magnitude);
      type  = hReq(ct).getData('type');
      strOLPhases = sprintf('%s%s, ', strOLPhases, mat2str(xdata));
      strOLGains  = sprintf('%s%s, ', strOLGains, mat2str(ydata));
      strGPBType  = sprintf('%s''%s'', ', strGPBType, type);
   end
   xdata = hReq(nReq).getData('xData');
   xdata = unitconv(xdata,hReq(nReq).getData('xunits'),DisplayUnits.Phase);
   ydata = hReq(nReq).getData('yData');
   ydata = unitconv(ydata,hReq(nReq).getData('yunits'),DisplayUnits.Magnitude);
   type  = hReq(nReq).getData('type');
   strOLPhases = sprintf('%s%s}', strOLPhases, mat2str(xdata));
   strOLGains  = sprintf('%s%s}', strOLGains, mat2str(ydata));
   strGPBType  = sprintf('%s''%s''}', strGPBType, type);
else
   %Single bound, create a string for an array with bound data
   xdata = hReq.getData('xData');
   xdata = unitconv(xdata,hReq.getData('xunits'),DisplayUnits.Phase);
   ydata = hReq.getData('yData');
   ydata = unitconv(ydata,hReq.getData('yunits'),DisplayUnits.Magnitude);
   strOLPhases = mat2str(xdata);
   strOLGains  = mat2str(ydata);
   strGPBType  = sprintf('''%s''',hReq.getData('type'));
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

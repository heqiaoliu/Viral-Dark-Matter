function ok = setBounds(hBlk,hC,varargin)
%

% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3.2.1 $ $Date: 2010/06/21 18:06:54 $

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

%Check we were passed the expected requirement type
if ~isa(hReq,'srorequirement.bodegain') && ~isempty(hReq)
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errInvalidReqType',getFullName(hBlk), ...
      'srorequirement.bodegain',class(hReq))
end

if haveDisplayedReq
   DisplayUnits = struct(...
      'Magnitude', hC(1).getDisplayUnits('yunits'), ...
      'Frequency', hC(1).getDisplayUnits('xunits'));
else
   DisplayUnits = struct(...
      'Magnitude', hBlk.MagnitudeUnits, ...
      'Frequency', hBlk.FrequencyUnits);
end

%Serialize the upper and lower bound data
if isempty(hReq)
   idxLower = [];
else
   idxLower = hReq.isLowerBound;
end
[strLFreq, strLMag] = localSerialize(hReq(idxLower),DisplayUnits);
[strUFreq, strUMag] = localSerialize(hReq(~idxLower),DisplayUnits);

%Push the data to block properties
blk = getFullName(hBlk);
ok = localUpdateBlockParameter(hBlk,blk, ...
   {'UpperBoundFrequencies', 'UpperBoundMagnitudes','LowerBoundFrequencies','LowerBoundMagnitudes'}, ...
   {strUFreq, strUMag, strLFreq, strLMag}, silentFlag, ...
   'Slcontrol:slctrlblkdlgs:txtUpdateBound');
if ok
   %Bound data was successfully updated, update block units
   hBlk.MagnitudeUnits = DisplayUnits.Magnitude;
   hBlk.FrequencyUnits = DisplayUnits.Frequency;
end
end

function [strFreq,strMag] = localSerialize(hReq,DisplayUnits)
% Helper function to serialize requirement data to write to a block
% parameter

nReq = numel(hReq);
if nReq == 0
   strFreq = '[]';
   strMag = '[]';
   return
end

if nReq > 1
   %Multiple bounds, create a string for a cell array with bound data
   strFreq = '{ ';
   strMag = '{ ';
   for ct = 1:nReq-1
      [fdata,mdata] = localGetBoundData(hReq(ct),DisplayUnits);
      strFreq = sprintf('%s%s, ', strFreq, mat2str(fdata));
      strMag  = sprintf('%s%s, ', strMag, mat2str(mdata));
   end
   [fdata,mdata] = localGetBoundData(hReq(nReq),DisplayUnits);
   strFreq = sprintf('%s%s }', strFreq, mat2str(fdata));
   strMag  = sprintf('%s%s }', strMag, mat2str(mdata));
else
   %Single bound, create a string for an array with bound data
   [xdata,ydata] = localGetBoundData(hReq,DisplayUnits);
   strFreq = mat2str(xdata);
   strMag  = mat2str(ydata);
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

function [xdata, ydata] = localGetBoundData(hReq,DisplayUnits)
%Helper function to return x & y data to push to block parameters

xdata = hReq.getData('xdata');
xdata = unitconv(xdata,hReq.getData('xunits'),DisplayUnits.Frequency);
ydata = hReq.getData('ydata');
ydata = unitconv(ydata,hReq.getData('yunits'),DisplayUnits.Magnitude);
openend = hReq.getData('OpenEnd');
if openend(1)
   %Bound extends to -inf
   xdata = [-inf xdata(1); xdata];
   yd = ydata(2)-ydata(1);
   if yd > 0
      ydata = [-inf ydata(1); ydata];
   elseif yd < 0
      ydata = [inf ydata(1); ydata];
   else
      ydata = [ydata(1) ydata(1); ydata];
   end
end
if openend(2)
   %Bound extends to +inf
   xdata = [xdata; xdata(end) +inf];
   yd = ydata(end)-ydata(end-1);
   if yd > 0
      ydata = [ydata; ydata(end) inf];
   elseif yd < 0
      ydata = [ydata; ydata(end) -inf];
   else
      ydata = [ydata; ydata(end) ydata(end)];
   end
end
end

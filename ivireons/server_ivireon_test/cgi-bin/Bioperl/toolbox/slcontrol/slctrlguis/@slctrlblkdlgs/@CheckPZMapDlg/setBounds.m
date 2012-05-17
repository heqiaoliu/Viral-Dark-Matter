function ok = setBounds(hBlk,hC,varargin)
%

% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3.2.2 $ $Date: 2010/07/06 14:42:21 $

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
hDamping  = [];
hNatFreq  = [];
hSettling = [];
for ct=1:numel(hReq)
   if isa(hReq(ct),'srorequirement.dampingratio') 
      hDamping = vertcat(hDamping,hReq(ct)); %#ok<AGROW>
   end
   if isa(hReq(ct),'srorequirement.naturalfrequency')
      hNatFreq = vertcat(hNatFreq,hReq(ct)); %#ok<AGROW>
   end
   if isa(hReq(ct),'srorequirement.settlingtime')
      hSettling = vertcat(hSettling,hReq(ct)); %#ok<AGROW>
   end
end
if isempty(hDamping) && isempty(hNatFreq) && isempty(hSettling) && ~isempty(hReq)
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errInvalidReqType',getFullName(hBlk), ...
      'srorequirement.settlingtime, srorequirement.dampingratio, srorequirement.naturalfrequency',class(hReq))
end
if ~isempty(hDamping)
   names = get(hDamping,{'Name'});
   if ~all( strcmp(names,'overshoot') | strcmp(names,'damping'))
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errInvalidDampingRatioName',getFullName(hBlk));
   end
end

if haveDisplayedReq && ~isempty(hNatFreq);
   idx = find(hNatFreq == hReq,1);
   DisplayUnits = struct(...
      'Magnitude', hBlk.MagnitudeUnits, ...
      'Phase',     hBlk.PhaseUnits, ...
      'Frequency', hC(idx).getDisplayUnits('xunits'));
else
   DisplayUnits = struct(...
      'Magnitude', hBlk.MagnitudeUnits, ...
      'Phase',     hBlk.PhaseUnits, ...
      'Frequency', hBlk.FrequencyUnits);
end

%Serialize the settling time bounds
strSettling = localSerialize(hSettling);
%Serialize the damping ratio bounds
if isempty(hDamping)
   idx = [];
else
   idx = strcmp(get(hDamping,{'Name'}),'overshoot');
end
strOvershoot = localSerialize(hDamping(idx));
strDamping   = localSerialize(hDamping(~idx));
%Serialize the natural frequency bounds
strNatFreq = localSerialize(hNatFreq,DisplayUnits);
   
%Push the data to block properties
blk = getFullName(hBlk);
ok = localUpdateBlockParameter(hBlk,blk, ...
   {'SettlingTime', 'PercentOvershoot', 'DampingRatio', 'NaturalFrequency'}, ...
   {strSettling, strOvershoot, strDamping, strNatFreq}, ...
   silentFlag, ...
   'Slcontrol:slctrlblkdlgs:txtUpdateBound');
if ~isempty(hNatFreq)
   if strcmp(hNatFreq(1).getData('type'),'lower')
      hBlk.NaturalFrequencyBound = '>=';
   else
      hBlk.NaturalFrequencyBound = '<=';
   end
end

if ok
   %Bound data was successfully updated, update block units
   hBlk.FrequencyUnits = DisplayUnits.Frequency;
end
end

function strVal = localSerialize(hReq,DisplayUnits)
% Helper function to serialize requirement data to write to a block
% parameter

if nargin < 2
   DisplayUnits = [];
end

nReq = numel(hReq);
if nReq == 0
   strVal = '[]';
   return
end

if nReq > 1
   %Multiple bounds, create a string for a cell array with bound data
   strVal = '{ ';
   for ct = 1:nReq-1
      data = localGetBoundData(hReq(ct),DisplayUnits);
      strVal = sprintf('%s%s, ', strVal, mat2str(data));
   end
   data = localGetBoundData(hReq(nReq),DisplayUnits);
   strVal = sprintf('%s%s }', strVal, mat2str(data));
else
   %Single bound, create a string for an array with bound data
   data = localGetBoundData(hReq,DisplayUnits);
   strVal = mat2str(data);
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

function data = localGetBoundData(hReq,DisplayUnits)
%Helper function to return data to push to block parameters

if isa(hReq,'srorequirement.dampingratio') && strcmp(hReq.Name,'overshoot')
   data = hReq.overshoot;
else
   data = hReq.getData('xdata');
end

if isa(hReq,'srorequirement.naturalfrequency')
   data = unitconv(data,hReq.getData('xunits'),DisplayUnits.Frequency);
end
end

function bnds = getBounds(hBlk)

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:41 $

% GETBOUNDS static method to return requirement object(s) described by
% the Bode check block
%

%Get units used by block to represent bounds. Bound data is always
%stored in display units by the block but requirements objects use "store"
%units and so conversion may be necessary.
units = struct(...
   'Phase', hBlk.PhaseUnits,...
   'Magnitude', hBlk.MagnitudeUnits, ...
   'Frequency', hBlk.FrequencyUnits);

blk = getFullName(hBlk);

%Construct Settling time bound
bnds = {};
try 
   val = slResolve(hBlk.SettlingTime,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','SettlingTime',blk)
end
isEnabled = strcmp(hBlk.EnableSettlingTime,'on');
if numel(val) > 0
   try
      bnds = vertcat(bnds,localCreateSettling(val,isEnabled));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','SettlingTime',blk)
   end
end

%Construct Overshoot bound
try
   val = slResolve(hBlk.PercentOvershoot,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPercent','PercentOvershoot',blk);
end
isEnabled = strcmp(hBlk.EnablePercentOvershoot,'on');
if numel(val) > 0
   try
      bnds = vertcat(bnds,localCreateOvershoot(val,isEnabled,false));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPercent','PercentOvershoot',blk)
   end
end

%Construct Damping-ratio bound
try
   val = slResolve(hBlk.DampingRatio,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropZeroOne','DampingRatio',blk);
end
isEnabled = strcmp(hBlk.EnableDampingRatio,'on');
if numel(val) > 0
   try
      bnds = vertcat(bnds,localCreateOvershoot(val,isEnabled,true));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropZeroOne','DampingRatio',blk)
   end
end

%Construct Natural frequency bound
try
   val = slResolve(hBlk.NaturalFrequency,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','NaturalFrequency',blk);
end
isEnabled = strcmp(hBlk.EnableNaturalFrequency,'on');
if numel(val) > 0
   try
      bnds = vertcat(bnds,localCreateNatFreq(val,isEnabled,hBlk.NaturalFrequencyBound,units));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','NaturalFrequency',blk)
   end
end

end

function bnds = localCreateSettling(val,isEnabled)
%Helper function to create a settling time requirement

if ~iscell(val), val = {val}; end
n = numel(val);
sz = num2cell(size(val));
bnds(sz{:}) = srorequirement.settlingtime;
localSetSettlingTimeData(bnds(end),val{end},isEnabled)
for ct=n-1:-1:1
   bnds(ct) = srorequirement.settlingtime;
   localSetSettlingTimeData(bnds(ct),val{ct},isEnabled)
end

%Place in array of requirements in cell array
bnds = {bnds};
end

function localSetSettlingTimeData(hReq,val,isEnabled)
%Helper function to parse block bound data and set requirement data

if ~isfinite(val) || ~isreal(val) || ~isscalar(val) || val < 0
   %Settling time must be positive real scalar
   error('id:id','dummy error')
end
hReq.setData('xdata',val)
hReq.FeedbackSign = 0;
hReq.isEnabled = isEnabled;
end

function bnds = localCreateOvershoot(val,isEnabled,isDamping)
%Helper function to create a settling time requirement

if ~iscell(val), val = {val}; end
n = numel(val);
sz = num2cell(size(val));
bnds(sz{:}) = srorequirement.dampingratio;
localSetOvershootData(bnds(end),val{end},isEnabled,isDamping)
for ct=n-1:-1:1
   bnds(ct) = srorequirement.dampingratio;
   localSetOvershootData(bnds(ct),val{ct},isEnabled,isDamping)
end

%Place in array of requirements in cell array
bnds = {bnds};
end

function localSetOvershootData(hReq,val,isEnabled,isDamping)
%Helper function to parse block bound data and set requirement data

if ~isfinite(val) || ~isreal(val) || ~isscalar(val) || val < 0
   %Percent overshoot & damping ration must be positive real scalar
   error('id:id','dummy error')
end
%Damping ratio must be <=1 percent overshoot <=100
if isDamping
   maxVal = 1;
else
   maxVal = 100;
end
if val > maxVal
   error('id:id','dummy error')
end

%Convert provided percent overshoot into an equivalent damping ratio
if ~isDamping
   if val <= 0
      val = 1;
   else
      val = min(val,100);
      t = (log(val/100)/pi)^2;
      val = sqrt(t/(1+t));
   end
end

%Set requirement data
hReq.setData('xdata',val)
if isDamping
   hReq.Name = 'damping';
else
   hReq.Name = 'overshoot';
end
hReq.FeedbackSign = 0;
hReq.isEnabled = isEnabled;
end

function bnds = localCreateNatFreq(val,isEnabled,type,units)
%Helper function to create a natural frequency requirement

if ~iscell(val), val = {val}; end
n = numel(val);
sz = num2cell(size(val));
bnds(sz{:}) = srorequirement.naturalfrequency;
localSetNatFreqData(bnds(end),val{end},isEnabled,type,units)
for ct=n-1:-1:1
   bnds(ct) = srorequirement.naturalfrequency;
   localSetNatFreqData(bnds(ct),val{ct},isEnabled,type,units)
end

%Place in array of requirements in cell array
bnds = {bnds};
end

function localSetNatFreqData(hReq,val,isEnabled,type,units)
%Helper function to parse block bound data and set requirement data

if ~isfinite(val) || ~isreal(val) || ~isscalar(val) || val < 0
   %Natural frequency must be positive real scalar
   error('id:id','dummy error')
end
hReq.FeedbackSign = 0;
hReq.isEnabled = isEnabled;
if strcmp(type,'>=')
   hReq.setData(...
      'xdata', unitconv(val,units.Frequency,hReq.getData('xunits')), ...
      'type', 'lower')
else
   hReq.setData(...
      'xdata', unitconv(val,units.Frequency,hReq.getData('xunits')), ...
      'type', 'upper')
end
end



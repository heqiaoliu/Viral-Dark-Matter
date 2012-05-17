function bnds = getBounds(hBlk)

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/04/30 00:44:08 $

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

%Get feedback sign for closed-loop requirements
fbsign = slResolve(hBlk.FeedbackSign,blk);

%Construct margin bounds
bnds = {};
try 
   gm = slResolve(hBlk.GainMargin,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','GainMargin',blk)
end
try 
   pm = slResolve(hBlk.PhaseMargin,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','PhaseMargin',blk)
end
isEnabled = strcmp(hBlk.EnableMargins,'on');
if numel(gm) > 0 || numel(pm)
   try
      bnds = vertcat(bnds,localCreateGPM(gm,pm,isEnabled,units,fbsign));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','GainMargin & PhaseMargin',blk)
   end
end

%Construct closed-loop peak gain bound
try 
   val = slResolve(hBlk.CLPeakGain,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','CLPeakGain',blk)
end
isEnabled = strcmp(hBlk.EnableCLPeakGain,'on');
if numel(val) > 0
   try
      bnds = vertcat(bnds,localCreatePeakGain(val,isEnabled,units,fbsign));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','CLPreakGain',blk)
   end
end

%Construct Nichols location bound
try
   phs  = slResolve(hBlk.OLPhases,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
      'OLPhases',blk,'OLGains','OLPhases');
end
try   
   mags  = slResolve(hBlk.OLGains,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
      'OLGains',blk,'OLPhases','OLPhases');
end
types = slResolve(hBlk.GainPhaseBoundType,blk);
isEnabled = strcmp(hBlk.EnableGainPhaseBound,'on');
if numel(mags) > 0
   try
      bnds = vertcat(bnds,localCreateGPLocation(mags,phs,types,isEnabled,units,fbsign));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
         'OLPhases',blk,'OLGains', 'OLPhases')
   end
end
end

function bnds = localCreateGPM(gm,pm,isEnabled,units,fbsign)
%Helper function to create a gain/phase margin requirement

if ~iscell(gm), gm = {gm}; end
if ~iscell(pm), pm = {pm}; end
n = numel(gm);
if numel(pm) ~= n
   error('id:id','dummy error')
end
sz = num2cell(size(gm));
bnds(sz{:}) = srorequirement.gainphasemargin;
localSetGPMData(bnds(n),gm{n},pm{n},isEnabled,units,fbsign)
for ct=n-1:-1:1
   bnds(ct) = srorequirement.gainphasemargin;
   localSetGPMData(bnds(ct),gm{ct},pm{ct},isEnabled,units,fbsign)
end

%Place in array of requirements in cell array
bnds = {bnds};
end

function localSetGPMData(hReq,gm,pm,isEnabled,units,fbsign)
%Helper function to parse block bound data and set requirement data

if ~isempty(gm) && (~isfinite(gm) || ~isreal(gm) || ~isscalar(gm) || gm < 0)
   %Gain margin must be positive real scalar
   error('id:id','dummy error')
end
if ~isempty(pm) && (~isfinite(pm) || ~isreal(pm) || ~isscalar(pm) || pm < 0)
   %Phase margin must be positive real scalar
   error('id:id','dummy error')
end

if isempty(pm)
   type = 'gain';
   pm   = 30;
elseif isempty(gm)
   type = 'phase';
   gm   = 20;
else 
   type = 'both';
end

hReq.setData('type',type,...
   'yData',unitconv(gm,units.Magnitude,hReq.getData('yunits')),...
   'xData',unitconv(pm,units.Phase,hReq.getData('xunits')))
hReq.FeedbackSign = fbsign;
hReq.isEnabled = isEnabled;
end

function bnds = localCreatePeakGain(val,isEnabled,units,fbsign)
%Helper function to create a CL Peak gain requirement

if ~iscell(val), val = {val}; end
n = numel(val);
sz = num2cell(size(val));
bnds(sz{:}) = srorequirement.nicholspeak;
localSetPeakGainData(bnds(n),val{n},isEnabled,units,fbsign)
for ct=n-1:-1:1
   bnds(ct) = srorequirement.nicholspeak;
   localSetPeakGainData(bnds(ct),val{ct},isEnabled,units,fbsign)
end

%Place in array of requirements in cell array
bnds = {bnds};
end

function localSetPeakGainData(hReq,val,isEnabled,units,fbsign)
%Helper function to parse block bound data and set requirement data

if ~isfinite(val) || ~isreal(val) || ~isscalar(val) || val < 0
   %Settling time must be positive real scalar
   error('id:id','dummy error')
end

hReq.setData('yData',unitconv(val,units.Magnitude,hReq.getData('yunits')))
hReq.FeedbackSign = fbsign;
hReq.isEnabled = isEnabled;
end

function bnds = localCreateGPLocation(mag,phs,type,isEnabled,units,fbsign)

%Construct array of requirements. Array is dimensionally commensurate with
%the cell array dimensions of the passed magnitude/frequency data
if ~iscell(mag), mag = {mag}; end
if ~iscell(phs), phs = {phs}; end
if ~iscell(type), type = {type}; end
if ~all(strcmp(type,'upper') | strcmp(type,'lower'))
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errNicholsGainPhaseBoundType',blk,'OLPhases','{''upper'', ''lower''}');
end
n  = numel(phs);
sz = num2cell(size(phs));
nt = length(type);
if nt > n
   type = type(1:n);
elseif nt < n
   type = vertcat(type(:),repmat({'upper'},n-nt,1)); 
end
bnds(sz{:}) = srorequirement.nicholslocation;
localSetBoundData(bnds(n),phs{n},mag{n},type{n},isEnabled,units,fbsign)
for ct = n-1:-1:1
   bnds(ct) = srorequirement.nicholslocation;
   localSetBoundData(bnds(ct),phs{ct},mag{ct},type{end},isEnabled,units,fbsign)
end

%Place in array of requirements in cell array
bnds = {bnds};
end

function localSetBoundData(hReq,phs,mag,type,isEnabled,units,fbsign)
%Helper function to parse block bound data and set requirement data

openend = false(1,2);
if isinf(phs(1)) 
   openend(1) = true;
   phs = phs(2:end,:);
   mag = mag(2:end,:);
end
if isempty(phs)
   error('id:id','dummy error');
end
if isinf(phs(end))
   openend(2) = true;
   phs = phs(1:end-1,:);
   mag = mag(1:end-1,:);
end
if isempty(phs)
   error('id:id','dummy error');
end

hReq.setData(...
   'type', type, ...
   'xdata', unitconv(phs,units.Phase,hReq.getData('xunits')), ...
   'ydata', unitconv(mag,units.Magnitude,hReq.getData('yunits')), ...
   'weight', ones(size(phs,1),1), ...
   'OpenEnd', openend)
hReq.isEnabled    = isEnabled;
hReq.FeedbackSign = fbsign;
end





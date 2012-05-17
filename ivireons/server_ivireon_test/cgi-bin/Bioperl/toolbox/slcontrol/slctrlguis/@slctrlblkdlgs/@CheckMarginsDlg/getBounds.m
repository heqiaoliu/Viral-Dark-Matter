function bnds = getBounds(hBlk)

% Author(s): A. Stothert 14-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/04/30 00:44:03 $

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
fbsign    = slResolve(hBlk.FeedbackSign,blk);
if numel(gm) > 0 || numel(pm) > 0
   try
      bnds = localCreateGPM(gm,pm,isEnabled,units,fbsign);
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','GainMargin & PhaseMargin',blk)
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
   'yData', unitconv(gm,units.Magnitude,hReq.getData('yunits')),...
   'xData', unitconv(pm,units.Phase,hReq.getData('xunits')))
hReq.FeedbackSign = fbsign;
hReq.isEnabled = isEnabled;
end
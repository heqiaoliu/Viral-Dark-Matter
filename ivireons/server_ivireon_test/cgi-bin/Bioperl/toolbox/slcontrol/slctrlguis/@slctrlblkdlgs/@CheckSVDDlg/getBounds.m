function bnds = getBounds(hBlk)
%

% Author(s): A. Stothert 14-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2.2.1 $ $Date: 2010/06/24 19:45:30 $

% GETBOUNDS static method to return requirement object(s) described by
% the Bode check block
%

%Get units used by block to represent bounds. Bound data is always
%stored in display units by the block but requirements objects use "store"
%units and so conversion may be necessary.
units = struct(...
   'Magnitude', hBlk.MagnitudeUnits,...
   'Frequency', hBlk.FrequencyUnits);

blk = getFullName(hBlk);

%Construct upper bound requirements from the block data
bnds = {};
try
   mag  = slResolve(hBlk.UpperBoundMagnitudes,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
      'UpperBoundMagnitudes',blk,'UpperBoundFrequencies','UpperBoundFrequencies');
end
try   
   frq  = slResolve(hBlk.UpperBoundFrequencies,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
      'UpperBoundFrequencies',blk,'UpperBoundMagnitudes','UpperBoundFrequencies');
end
isEnabled = strcmp(hBlk.EnableUpperBound,'on');
type      = 'upper';
if numel(mag) > 0
   try
      bnds = vertcat(bnds,localCreateRequirement(mag,frq,type,isEnabled,units));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
         'UpperBoundFrequencies',blk,'UpperBoundMagnitudes', 'UpperBoundFrequencies')
   end
end

%Construct lower bound requirements from the block data
try
   mag = slResolve(hBlk.LowerBoundMagnitudes,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
      'LowerBoundMagnitudes',blk,'LowerBoundFrequencies', 'LowerBoundFrequencies');
end
try
   frq = slResolve(hBlk.LowerBoundFrequencies,blk);
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
      'LowerBoundFrequencies',blk,'LowerBoundMagnitudes', 'LowerBoundFrequencies');
end
isEnabled = strcmp(hBlk.EnableLowerBound,'on');
type  = 'lower';
if numel(mag) > 0
   try
      bnds = vertcat(bnds,localCreateRequirement(mag,frq,type,isEnabled,units));
   catch E
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPWLEdges',...
         'LowerBoundFrequencies',blk,'LowerBoundMagnitudes', 'LowerBoundFrequencies');
   end
end
end

function bnds = localCreateRequirement(mag,frq,type,isEnabled,units)

%Construct array of requirements. Array is dimensionally commensurate with
%the cell array dimensions of the passed magnitude/frequency data
if ~iscell(mag), mag = {mag}; end
if ~iscell(frq), frq = {frq}; end
n  = numel(frq);
sz = num2cell(size(frq));
bnds(sz{:}) = srorequirement.svdgain;
localSetBoundData(bnds(n),frq{n},mag{n},type,isEnabled,units)
for ct = n-1:-1:1
   bnds(ct) = srorequirement.svdgain;
   localSetBoundData(bnds(ct),frq{ct},mag{ct},type,isEnabled,units)
end

%Place in array of requirements in cell array
bnds = {bnds};
end

function localSetBoundData(hReq,frq,mag,type,isEnabled,units)
%Helper function to parse block bound data and set requirement data

openend = false(1,2);
if isinf(frq(1)) || frq(1) == 0
   openend(1) = true;
   frq = frq(2:end,:);
   mag = mag(2:end,:);
end
if isempty(frq)
   error('id:id','dummy error');
end
if isinf(frq(end))
   openend(2) = true;
   frq = frq(1:end-1,:);
   mag = mag(1:end-1,:);
end
if isempty(frq)
   error('id:id','dummy error');
end

hReq.setData(...
   'type', type, ...
   'xdata', unitconv(frq,units.Frequency,hReq.getData('xunits')), ...
   'ydata', unitconv(mag,units.Magnitude,hReq.getData('yunits')), ...
   'weight', ones(size(frq,1),1), ...
   'OpenEnd', openend)
hReq.isEnabled = isEnabled;
end

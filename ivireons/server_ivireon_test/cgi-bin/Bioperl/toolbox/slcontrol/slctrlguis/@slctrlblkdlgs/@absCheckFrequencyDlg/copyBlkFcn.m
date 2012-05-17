function copyBlkFcn(blk) 
%
 
% Author(s): A. Stothert 09-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/30 00:44:20 $

% COPYBLKFCN  static method on all frequency domain check blocks for when
% the block is copied

if isempty(getlinio(blk))
   %Only copy model ios if the block has none defined
   ios = getlinio(bdroot(blk));
   try %#ok<TRYNC>
      %IOs from getlinio may be in modelrefs which are not supported by the
      %check blocks, so silently error
   setlinio(blk,ios);
end
end

%If they are not defined set the block units to CST prefs units 
prefs = cstprefs.tbxprefs;
if isempty(get_param(blk,'FrequencyUnits'))
   set_param(blk,'FrequencyUnits',prefs.FrequencyUnits)
end
if isempty(get_param(blk,'MagnitudeUnits'))
   set_param(blk,'MagnitudeUnits',prefs.MagnitudeUnits)
end
if isempty(get_param(blk,'PhaseUnits'))
   set_param(blk,'PhaseUnits',prefs.PhaseUnits)
end

%Make sure a CheckBlkExecutionEngine exists for the model. This ensures
%there is a listener for model EnginePreCompStart events so that the model
%can be configured for linearization.
eng = linearize.CheckBlkExecutionManager.getInstance(bdroot(blk));
if isempty(eng)
   ctrlMsgUtils.error('SLControllib:checkpack:errUnexpected','Failed to create linearization engine');
end
end

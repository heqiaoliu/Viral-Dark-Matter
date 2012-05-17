function syncLinIOData(this) 
%

% SYNCLINIODATA update dialog IO data with block IO data
%
 
% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:44 $

hBlk = this.getBlock;
blk = getFullName(hBlk);
if ~isempty(hBlk.LinearizationIOs)
   try
      this.LinearizationIOs = slResolve(hBlk.LinearizationIOs,blk);
   catch E %#ok<NASGU>
      ctrlMsgUtils.warning('Slcontrol:slctrlblkdlgs:errLinearizationIOs',blk)
      this.LinearizationIOs = {};
   end
end
end
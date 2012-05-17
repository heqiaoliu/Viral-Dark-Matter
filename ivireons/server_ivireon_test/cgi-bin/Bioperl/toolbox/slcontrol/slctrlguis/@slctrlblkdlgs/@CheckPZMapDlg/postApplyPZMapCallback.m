function [status, errmsg] = postApplyPZMapCallback(this,dlg) 
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:35 $

% POSTAPPLYBODECALLBACK manage post apply actions for the dialog
%

%Quick return if called from locked library
[~, isLocked] = this.isLibraryBlock(this.getBlock);
if isLocked
   status = true;
   errmsg = '';
   return;
end

% Call parent class postapply callbacks
[status,errmsg] = this.postApplyLinearizationCallback(dlg);

%If there is a view open we should update it
hBlk = get_param(strcat(getFullName(this.getBlock),'/Check Freq. Characteristics'),'Object');
blkVis = getappdata(hBlk,'BlockVisualization');
if ~isempty(blkVis) && ishandle(blkVis)
   hReqExt = blkVis.getExtInst('Tools:Requirement viewer');
   if ~isempty(hReqExt)
      hReqExt.updateVisualizationBounds
   end
end
end
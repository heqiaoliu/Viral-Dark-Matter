function [status, errmsg] = postApplyMarginsCallback(this,dlg)

% Author(s): A. Stothert 12-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:08 $

% POSTAPPLYBODECALLBACK manage post apply actions for the Bode dialog
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
   if this.newPlotPostApply
      %Delete the currently used view and update with a new one
      showPlot = strcmp(get(blkVis.Parent,'Visible'),'on');
      pos = get(blkVis.getGUI.WidgetHandle,'Position');
      set(this.getBlock,'ViewDlgPos',mat2str(pos));
      blkVis.close;
      setappdata(hBlk,'BlockVisualization',[]);
      setappdata(hBlk,'BlockVisualizationData',[]);
      if showPlot
         checkpack.absCheckDlg.openBlkView(this.getBlock);
      end
   else
      %Update the current view
      hReqExt = blkVis.getExtInst('Tools:Requirement viewer');
      if ~isempty(hReqExt)
         hReqExt.updateVisualizationBounds
      end
      
   end
end
end
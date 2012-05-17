function [status, errmsg] = preApplyMarginsCallback(this,dlg) 
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:09 $

% PREAPPLYBODECALLBACK manage preapply actions for the Bode dialog
%

%Quick return if called from locked library, or if no unapplied changes
hasChanges  = dlg.hasUnappliedChanges;
[~, isLocked] = this.isLibraryBlock(this.getBlock);
if isLocked || ~hasChanges
   status = true;
   errmsg = '';
   return;
end

% Call parent class preapply callbacks
[status, errmsg] = this.preApplyLinearizationCallback(dlg);

%Check whether the plot type has changed
idxNew =dlg.getWidgetValue('PlotType')+1; %one based Matlab indexing
enums = findtype('slctrlblkdlgs_enumGPMPlotType');
this.newPlotPostApply = ~strcmp(enums.Strings{idxNew},this.PlotType);

if status
   % Finally call the Simulink super class default preApplyCallback implementation
   [status, errmsg] = this.preApplyCallback(dlg);
end
end
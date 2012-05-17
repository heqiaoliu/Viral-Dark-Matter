function Contents = getContents(this)
%GETCONTENTS  Queries current configuration of the SISO Tool LTI Viewer.
%
%   CONTENTS = GETCONTENTS(THIS) reads the current configuration of the 
%   SISO Tool LTI Viewer.  CONTENTS is a struct array with as many entries 
%   as plot, and fields
%     * PlotType:      a string specifying the plot type (alias)
%     * VisibleModels: the list of visible loop transfers (specified as
%                      indices relative to SystemInfo).
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2005/12/22 17:44:15 $
ActiveViews = getCurrentViews(this);
ActiveViewTypes = get(ActiveViews,{'Tag'});
Contents = struct('PlotType',ActiveViewTypes(:),'VisibleModels',[]);
for ct=1:length(ActiveViews)
   RespVis = get(ActiveViews(ct).Responses,'Visible');
   idxVis = find(strcmp(RespVis,'on'));
   Contents(ct).VisibleModels = idxVis(idxVis<=length(this.SystemInfo));
end

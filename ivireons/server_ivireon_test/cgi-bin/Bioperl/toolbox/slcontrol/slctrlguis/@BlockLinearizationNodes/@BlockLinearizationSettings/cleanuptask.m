function cleanuptask(this)
% CLEANUPTASK
%  Task to clean up ltiviewers if a task is removed
%

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:43:41 $

%% Delete the ltiviewer in the linearization task if needed
if isa(this.LTIViewer,'viewgui.ltiviewer')
    close(this.LTIViewer.Figure);
end

%% Delete the ltiviewers in the views if needed
Children = this.getChildren;
Views = Children(end).getChildren;
for ct = 1:length(Views)
    if isa(Views(ct).LTIViewer,'viewgui.ltiviewer')
        close(Views(ct).LTIViewer.Figure);
    end
end

function bool = isVisible(this)
%ISVISIBLE  Checks if Automated Tuning panel is visible.

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/17 13:24:49 $

bool = ~isempty(this.Parent.DesignTask) && strcmp(this.Parent.DesignTask.getVisibleTab,'SROTuning');

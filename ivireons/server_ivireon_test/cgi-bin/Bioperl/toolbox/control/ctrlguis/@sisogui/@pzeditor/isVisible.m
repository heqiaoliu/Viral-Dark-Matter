function bool = isVisible(this)
%ISVISIBLE  Checks if PZ Editor is visible.

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:43:02 $

if ~isempty(this.Parent.DesignTask)
    bool = strcmp(this.Parent.DesignTask.getVisibleTab,'PZEditor');
else
    bool = false;
end
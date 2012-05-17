function bool = isVisible(this);
% Checks if sisotask is visible

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:49:59 $

[projectframe,workspace] = slctrlexplorer;

if projectframe.isVisible %% && ~(projectframe.getExtendedState == 1)
    bool = true;
else
    bool = false;
end
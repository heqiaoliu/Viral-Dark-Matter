function Constraints = findconstr(this)
%

%FINDCONSTR Finds all active design constraints objects attached to a
%plot

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:37:53 $

%Remove any stale requirements that may have been deleted
this.Requirements(~ishandle(this.Requirements)) = [];

%Return the list of requirements
Constraints = this.Requirements;
end


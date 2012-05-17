function cline = changedependvar(cline,newvar)
% CHANGEDEPENDVAR  Change dependent variable.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.1.4.2 $  $Date: 2005/09/12 18:58:34 $

cline.DependVar = newvar;
update(cline);
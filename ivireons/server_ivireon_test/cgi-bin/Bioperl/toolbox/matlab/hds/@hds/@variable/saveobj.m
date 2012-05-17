function SavedData = saveobj(this)
% SAVE method for @variable class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:14:59 $

% Serialize variable as its name
SavedData = this.Name;
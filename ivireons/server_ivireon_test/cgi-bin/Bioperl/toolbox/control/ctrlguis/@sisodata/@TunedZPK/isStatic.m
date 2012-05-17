function boo = isStatic(this)
% Checks if compensator is static

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:26 $
boo = isempty(this.PZGroup);
function boo = isempty(this)
% Checks if no data has been imported

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/06/20 20:00:38 $
boo = isempty(this.G) || isempty(this.G(1).Model);
   
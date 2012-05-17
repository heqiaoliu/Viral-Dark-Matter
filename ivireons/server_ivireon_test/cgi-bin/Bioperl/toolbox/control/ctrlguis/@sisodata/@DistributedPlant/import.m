function import(this,G)
% Imports plant data.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/06/20 20:00:37 $
for ct=1:length(G)
   this.G(ct).import(G(ct))
end

% Reset P
this.P = [];
this.Psim = [];

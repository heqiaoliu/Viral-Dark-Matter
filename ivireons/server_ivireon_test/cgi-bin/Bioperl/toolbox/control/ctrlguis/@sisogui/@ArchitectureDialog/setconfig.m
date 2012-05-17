function setconfig(this,ConfigNum)
% Configures dialog for specified loop architecture.

%   Authors: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2006/05/27 18:02:32 $

if nargin>1
   % Update internal data
   ConfigData = sisoinit(ConfigNum);
   ConfigData = mapto(this.ConfigData,ConfigData,this.CurrentData);
   this.ConfigData = ConfigData;
else
   ConfigData = this.ConfigData;
end


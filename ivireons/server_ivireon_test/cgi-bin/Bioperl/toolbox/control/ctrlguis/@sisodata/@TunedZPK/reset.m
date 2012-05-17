function reset(this,Scope)
% Cleans up dependent data when core data changes.
%
%   RESET(this,'all')
%   RESET(this,'gain')

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:28 $

switch Scope
   case 'all'
       this.SSData.d = [];
       this.updateParams;
       
   case 'gain'
       this.updateParams;
end
function reset(this,Scope)
% Cleans up dependent data when core data changes.
%
%   RESET(this,'all')
%   RESET(this,'gain')

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:46:15 $

this.SSData.d = [];

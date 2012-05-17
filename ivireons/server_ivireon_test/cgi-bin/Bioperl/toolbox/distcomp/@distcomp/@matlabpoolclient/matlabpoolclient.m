function obj = matlabpoolclient
; %#ok Undocumented

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.2 $    $Date: 2008/08/08 12:51:30 $

obj = distcomp.matlabpoolclient;

obj.JobStartupTimeout = Inf;
obj.IsClientOnlySession = numlabs < 2;
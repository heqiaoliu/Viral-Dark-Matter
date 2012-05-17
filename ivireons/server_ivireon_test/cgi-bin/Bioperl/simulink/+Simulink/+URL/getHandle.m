function out = getHandle(url)
% GETHANDLE Convert Simulink URL to handle

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/09/28 20:45:05 $

h = Simulink.URL.parseURL(url);
out = h.getHandle;

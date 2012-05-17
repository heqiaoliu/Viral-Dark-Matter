function cleanupNotify()
%CLEANUPNOTIFY Notify Simulink 3D Animation objects that native engine is 
%   being removed from memory.
%
%   Not to be called directly.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/05/07 18:29:37 $ $Author: batserve $  

% close all worlds, closed or open, and wait for completion
vrclear -force;
vrdrawnow;

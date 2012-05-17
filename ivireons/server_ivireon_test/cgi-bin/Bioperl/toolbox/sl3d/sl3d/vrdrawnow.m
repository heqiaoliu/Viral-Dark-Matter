function vrdrawnow
%VRDRAWNOW Flush pending virtual reality scene events.
%   VRDRAWNOW flushes the queue of virtual reality scene changes and forces
%   viewers to update screen.
%   Normally, changes to virtual reality scene are queued and the views
%   are updated when one of the following happens:
%
%   - MATLAB is idle for some time (no Simulink model is running
%     and no MATLAB program is being executed).
%   - A Simulink step is finished.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/02/08 23:02:03 $ $Author: batserve $

vrsfunc('DrawNow');

function [olsys r2y r2u id2y od2y] = utPIDgetLoopfromC(C,G)
% PID helper function

% This function computes open loop GC, closed loop GC/(1+GC), input
% disturbance model G/(1+GC) and output disturbance model 1/(1+GC)
% G and C have to be in the same time domain and have the same sample time

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2010/03/26 17:21:34 $

hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
% use state space for gang of four when G is not frd
if ~isa(G,'frd')
    G = ss(G);
end
olsys = G*C;
r2y = feedback(olsys,1);
r2u = feedback(C,G);
id2y = feedback(G,C);
od2y = feedback(1,olsys);
if ~isproper(r2y)
    r2y = ss;
end

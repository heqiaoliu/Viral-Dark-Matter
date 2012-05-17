function op = updateopcond(this)
%% UPDATEOPCOND Get a copy of the latest operating point
%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:04:35 $

%% Create a copy of the operating point and check for a consistent set of
%  operating point
op = copy(this.OpPoint);
update(op,true);
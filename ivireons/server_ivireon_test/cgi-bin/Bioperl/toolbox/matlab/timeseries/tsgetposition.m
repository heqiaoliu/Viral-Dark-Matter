function pos = tsgetposition(pnl,  units)
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

% Get the position vector of a panel in the specified units
set(pnl,'Userdata',true);
oldunits = get(pnl,'Units');
set(pnl,'Units',units);
pos = get(pnl,'Position');
set(pnl,'Units',oldunits);
set(pnl,'Userdata',[]);
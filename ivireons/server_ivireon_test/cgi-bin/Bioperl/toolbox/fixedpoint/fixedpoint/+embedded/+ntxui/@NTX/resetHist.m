function resetHist(ntx)
% Reset Histogram and Dialog panel states, then update display.
% This is the public reset method.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:44 $

resetDataHist(ntx);
resetThresholds(ntx);

% It's intuitive to see signedness get reset to unsigned
updateSignedStatus(ntx);

% updateBar() also performs an updateDialogContent(), effectively updating
% all visible readouts in reaction to the reset condition.
updateBar(ntx,[]);

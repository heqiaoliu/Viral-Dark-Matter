function durationupdate(h,TXTendTime, TXTtimeStep,LBLnumSamples)
%DURATIONUPDATE - simsamples listener callback
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/04/21 03:06:53 $

if ~isempty(h.interval) && h.interval>0 && h.simsamples>0
    TXTendTime.setText(num2str((h.simsamples-1)*h.interval+h.starttime));
    TXTtimeStep.setText(num2str(h.interval));
end
LBLnumSamples.setText(sprintf('Number of samples: %s',num2str(h.simsamples)));
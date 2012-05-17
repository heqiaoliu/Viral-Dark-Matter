function [errorCount, transmissionCount] = IEEE80211bErrorCalculator(txProbe,rxProbe,userData)
%IEEE80211bErrorCalculator Error calculator function for the IEEE80211b system
%   Calculate number symbol errors for the current iteration

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/05/23 07:50:03 $

%Define a persistent variable to keep an actual data delay buffer
persistent txDataBuffer

delay = userData.TxRxDelay;

%Initialize txDataBuffer if userData.FirstFrameFlag is true
if userData.FirstFrameFlag
    txDataBuffer = zeros(delay,1);    
end

% Add delay in symbols to actual signal (Tx) to align with expected signal (Rx)
txDelayedProbe  = [txDataBuffer; txProbe(1:end-delay)];

% Store delayed symbols
if delay > 0
    txDataBuffer = txProbe(end-delay+1:end);
end

% Ignore delayed bits on first iteration, ignore initial state bit used for
% differential enconding
if userData.FirstFrameFlag
    tx = txDelayedProbe(delay+2:end);
    rx = rxProbe(delay+2:end);
else
    tx = txDelayedProbe;
    rx = rxProbe;
end

%Count the number of errors and number of transmissions
errorCount = symerr(tx,rx);
transmissionCount = length(tx);


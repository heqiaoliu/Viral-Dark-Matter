function [freqs,units] = freqcheck(freqsLHS,unitsLHS,freqsRHS,unitsRHS)
%FREQCHECK  Check compatibility of frequency vectors, considering units.
%           If either system has units of rad/s, return frequencies in
%           rad/s, otherwise, return frequencies in Hz.

%   Author: S. Almy
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2008/10/02 18:47:35 $


freqs = freqsLHS;
units = unitsLHS;
reltol = 1e3*eps;

% Unit alignment
if ~strcmpi(unitsLHS,unitsRHS)
    % Convert units to rad/sec
    if strncmpi(unitsRHS,'h',1)
        freqsRHS = freqsRHS*2*pi;
    else
        freqsLHS = freqsLHS*2*pi;
        freqs = freqsRHS;
        units = unitsRHS;
    end
end

% The frequency points in FREQLHS and FREQRHS should now match
% up to round-off errors of level RELTOL
if length(freqsLHS) ~= length(freqsRHS)
    ctrlMsgUtils.error('Ident:idfrd:freqcheck1')
elseif any(abs(freqsLHS-freqsRHS)>reltol*(1+freqsLHS))
    ctrlMsgUtils.error('Ident:idfrd:freqcheck2')
end

function s = allmargin(D,varargin)
%ALLMARGIN  Computes all stability margins and crossover frequencies.

%   Author(s): P.Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:11 $

% Convert frequency vector to rad/s (expected units for IMARGIN)
w = unitconv(D.Frequency,D.FreqUnits,'rad/s');

% Compute frequency response (will factor delays in)
h = fresp(D,w);
mag = abs(h);
phase = (180/pi)*unwrap(atan2(imag(h),real(h)),[],3);

% Compute gain and phase margins
s = allmargin(mag,phase,w,abs(D.Ts),getIODelay(D,'total'));

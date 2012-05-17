function w = commEDGE_getRaisedCosineWindow(Nsamp)
% commEDGE_getRaisedCosineWindow Design a rasied cosine window for modulation
% accuracy measurement of an EDGE signal as defined in [1].  This window has a
% raised cosine shape.
%
% W = commEDGE_getRaisedCosineWindow(Nsamp) design a filter with Nsamp samples
% per symbol and returns in W.
%
% Reference 1: 3GPP TS 45.005 v8.1.0, GSM/EDGE Radio Access Network; Radio
% transmission and reception, Release 8

%   Copyright 2008 The MathWorks, Inc.

Tnormal = 6/1625000;     % Normal sysmbol duration in seconds


% Cerate time and window vectors
t = 0:Tnormal/Nsamp:4*Tnormal;
w = size(t);

% Calculate the right half of the window
w(t<1.5*Tnormal) = 1;
tIdx = find((t>=1.5*Tnormal)&(t<3.75*Tnormal));
w(tIdx) = 0.5*(1+cos(pi*(t(tIdx)-1.5*Tnormal)/(2.25*Tnormal)));
w(t>=3.75*Tnormal) = 0;

% Add the left half
w = [w(end:-1:1) w(2:end)];

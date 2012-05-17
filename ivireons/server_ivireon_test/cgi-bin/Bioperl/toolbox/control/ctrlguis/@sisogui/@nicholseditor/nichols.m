function [m,p,w,Focus] = nichols(Editor,Dsys,w)
%NICHOLS  Computes frequency range and grid for Nichols plot.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.8 $ $Date: 2009/07/09 20:51:21 $

if nargin == 2
    w = [];
end

% Compute grid and response
[m,p,w,FocusInfo] = freqresp(Dsys,2,w,true);
p = (180/pi) * p;

% Eliminate NaN/Inf values near w=0 (due to integrators)
idx = find(cumsum(isfinite(m))>0);
w = w(idx);  m = m(idx);  p = p(idx);

% Focus data
Focus = FocusInfo.Focus;

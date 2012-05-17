function [m,p,w,Focus,SoftFocus] = bode(this,Dsys,w)
%BODE  Computes frequency range and grid for Bode plot.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.8 $ $Date: 2009/07/09 20:51:19 $

%   RE: Wrapper around GENFRESP. For single SISO model only.

if nargin == 2
    w = [];
end

% Compute grid and response
[m,p,w,FocusInfo] =  freqresp(Dsys,3,w,true);
p = (180/pi) * p;

% Eliminate NaN/Inf values near w=0 (due to integrators)
idx = find(cumsum(isfinite(m))>0);
w = w(idx);  m = m(idx);  p = p(idx);

% Focus data
Focus = FocusInfo.Focus;
SoftFocus = FocusInfo.Soft;


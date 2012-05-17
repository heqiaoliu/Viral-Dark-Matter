function [z,gain] = tzero(mod)
%TZERO  Transmission zeros of IDMODEL. Requires Control System Toolbox.
%  
%   Z = TZERO(M) returns the transmission zeros of the IDMODEL M. 
% 
%   [Z,GAIN] = TZERO(M) also returns the transfer function 
%   gain if the system is SISO.
%   
%   By default only the transmission zeros from the measured inputs are
%   computed. To obtain also the zeros from the noise inputs, first convert
%   these using NOISECNV.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.5 $ $Date: 2008/10/31 06:11:25 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','tzero')
end

mods = ss(mod('m'));
if nargout < 2
   z = tzero(mods);
else
   [z,gain] = tzero(mods);
end

function [sos,g,Astop] = alpfstop(h,N,Wp,Ws,Apass)
%ALPFSTOP   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/12/26 22:19:27 $

% Compute cutoff
Wc=sqrt(Wp*Ws);

% Design prototype
[sos,g,Astop] = apspecord(h,N,Wp/Wc,Apass); % Astop is a measurement

sos = stosbywc(h,sos,Wc);

% [EOF]

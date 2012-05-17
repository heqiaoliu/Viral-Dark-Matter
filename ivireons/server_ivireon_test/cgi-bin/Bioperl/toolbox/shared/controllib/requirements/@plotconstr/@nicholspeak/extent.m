function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:22 $

% Generate maximum points
gain = 10^(Constr.PeakGain/20);
phase = (360 + [-30 30]) * pi/180; % Marker points always in the range.   
z = gain .* exp(j*phase); % mesh in H/(1+H) plane

H = z ./ (1-z);
XData = Constr.OriginPha + rem((180/pi)*angle(H(:)) + 360, 360) - 180;
YData = 20*log10(abs(H(:)));

RangePha = unitconv([min(XData), max(XData)], 'deg', Constr.PhaseUnits);
RangeMag = unitconv([min(YData), max(YData)], 'dB',  Constr.MagnitudeUnits);
Extent = [RangePha, RangeMag];

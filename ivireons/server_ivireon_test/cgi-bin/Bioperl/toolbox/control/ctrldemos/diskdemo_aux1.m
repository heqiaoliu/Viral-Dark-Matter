function slide = diskdemo_aux1(flag)
%DISKDEMO  Digital servo control of a hard-disk drive auxiliary function.
%

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/04/03 03:08:47 $

switch flag
    case 1
        h = gcr;
        setoptions(h,'FreqUnits','Hz','MagUnits','dB','PhaseUnits','deg',...
            'Grid','on','XLimMode','Manual','XLim',{[1e2 1e4]},...
            'YLimMode','manual','YLim',{[-40,20],[-450,360]});
    case 2
        h = gcr;
        setoptions(h,'FreqUnits','Hz','Grid','on', ...
            'XLimMode','Manual','XLim',{[1e2 1e4]},...
            'YLimMode','manual','YLim',{[-40,30],[-450,360]});
end
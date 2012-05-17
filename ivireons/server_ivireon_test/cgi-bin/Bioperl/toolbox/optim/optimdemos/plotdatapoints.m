function h = plotdatapoints(t,y)
%PLOTDATAPOINTS Helper function for DATDEMO

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/01 07:21:11 $

h = plot(t,y,'b-');
axis([0 2 -0.5 6])
hold on
plot(t,y,'ro')    
title('Data points and fitted curve')
hold off

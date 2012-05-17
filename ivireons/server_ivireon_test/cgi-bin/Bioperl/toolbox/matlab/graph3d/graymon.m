function graymon
%GRAYMON Set graphics defaults for gray-scale monitors.
%   GRAYMON changes the default graphics properties to produce
%   legible displays for gray-scale monitors.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.6.4.2 $  $Date: 2009/10/24 19:17:58 $

ch = get(0,'children');
co = [.75 .5 .25]'*ones(1,3);
set(ch,'DefaultAxesColorOrder',co)
set(0,'DefaultAxesColorOrder',co)

function plot(chan)
%PLOT Plot channel object state information.
%  PLOT(CHAN) opens a graphical user interface that allows you to visualize
%  state information stored in channel object CHAN.  To store state
%  information in CHAN, set CHAN.StoreHistory to 1 and invoke Y =
%  FILTER(CHAN, X).  The number of channel states stored is equal to the
%  length of input signal X.  For example, CHAN stores a vector of path
%  gains for each input signal sample.
%
%  The graphical user interface allows you to choose from a number of
%  visualizations such as path gain history, multipath phasors, impulse
%  response, and frequency response.   
%  
%  See also RAYLEIGHCHAN, RICIANCHAN, CHANNEL/FILTER, CHANNEL/RESET.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:57:58 $

id = 'comm:channel_plot:InvalidChanPlot';
msg = sprintf([...
    'To visualize state information in a channel CHAN, use \n',...
    'PLOT(CHAN) where CHAN is a channel object.\n', ...
    'For more information, type ''help channel/plot'' in MATLAB.']);
error(id,msg)
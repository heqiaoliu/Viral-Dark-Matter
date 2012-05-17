function [w h] = destinationSize(this)
%DESTINATIONSIZE 

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:50:42 $

sz = gui_sizes(this);
w = 160*sz.pixf;
h = 40*sz.pixf;

% [EOF]

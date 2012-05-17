function [width height] = destinationSize(this)
%DESTINATIONSIZE 

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:50:35 $

sz = gui_sizes(this);

% Default frame height.
height = 100*sz.pixf;
width  = 160*sz.pixf;

% [EOF]

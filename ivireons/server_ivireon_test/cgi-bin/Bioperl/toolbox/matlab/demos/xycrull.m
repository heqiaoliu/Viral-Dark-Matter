function  [xt,yt] = xycrull(t)
%XYCRULL Function that returns the coordinate functions
%   for the eccentric ellipse that generates the cruller
%   in the M-file CRULLER.
 
%   C. Henry Edwards, University of Georgia. 6/20/93.
%
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.7.4.3 $  $Date: 2009/05/23 08:03:00 $

xt = 3*cos(t);   yt = sin(t);


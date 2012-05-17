function  [xt,yt] = xyklein(t)
%XYKLEIN Coordinate functions for the figure-8 that
%   generates the Klein bottle in KLEIN1.

%   C. Henry Edwards, University of Georgia. 6/20/93.
%
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2009/05/23 08:03:01 $

xt = sin(t);   yt = sin(2*t);

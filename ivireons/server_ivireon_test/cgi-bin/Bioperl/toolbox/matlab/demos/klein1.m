%% Klein Bottle
% Generate a Klein bottle by revolving the figure-eight curve defined by
% XYKLEIN.
% 
% Thanks to C. Henry Edwards, Dept. of Mathematics, University of 
% Georgia, 6/20/93.

% Copyright 1984-2005 The MathWorks, Inc.
% $Revision: 5.13.4.4 $  $Date: 2009/10/12 17:29:33 $

ab = [0 2*pi];
rtr = [2 0.5 1];
pq = [40 40];
box = [-3 3 -3 3 -2 2];
vue = [55 60];

clf
tube('xyklein',ab,rtr,pq,box,vue);
shading interp
colormap(pink);


displayEndOfDemoMessage(mfilename)
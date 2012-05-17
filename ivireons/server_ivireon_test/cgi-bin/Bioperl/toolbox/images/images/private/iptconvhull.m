function k = iptconvhull(xy)
%IPTCONVHULL Thin wrapper for CONVHULL.
%   K = IPTCONVHULL([X Y]) is equivalent to K = CONVHULL(X,Y).
%
%   See also CONVHULL.

%   Copyright 2005-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:15:27 $

x = xy(:,1);
y = xy(:,2);
k = convhull(x,y);

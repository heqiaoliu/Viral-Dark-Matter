function fig = fighndl(h)
%FIGHNDL  Gets handle of parent figure.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:52 $

if ishghandle(h.Axes(1),'axes')
   fig = h.Axes(1).Parent;
else
   fig = fighndl(h.Axes(1));
end

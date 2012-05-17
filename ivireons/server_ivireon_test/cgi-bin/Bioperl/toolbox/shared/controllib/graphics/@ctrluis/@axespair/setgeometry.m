function setgeometry(h,varargin)
%SETGEOMETRY  Sets grid geometry.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:01 $

% Pass new geometry to @plotpair (no listeners!)
h.Axes.Geometry = h.Geometry;

% Update plot
if h.Axes.Visible
   refresh(h.Axes)
end

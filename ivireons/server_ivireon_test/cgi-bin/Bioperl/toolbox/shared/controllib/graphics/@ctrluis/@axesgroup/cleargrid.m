function cleargrid(h,varargin)
%CLEARGRID  Clears grid lines.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:19 $

delete(h.GridLines(ishghandle(h.GridLines)))
h.GridLines = [];

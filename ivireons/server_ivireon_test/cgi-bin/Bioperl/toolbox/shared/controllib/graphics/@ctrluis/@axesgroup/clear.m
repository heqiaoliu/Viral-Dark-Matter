function clear(h)
%CLEAR  Clears wrapper object without destroying axes.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:18 $

h.Axes = [];
delete(h)
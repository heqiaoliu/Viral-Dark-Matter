function f = hgparent(Axes)
%HGPARENT  Gets handle of parent in HG hierarchy.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:40 $

f = get(Axes.Handle,'parent');
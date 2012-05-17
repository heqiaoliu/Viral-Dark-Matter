function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a view object.

%  Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:12 $
h = cat(3, this.FiniteSV, this.InfiniteSV);
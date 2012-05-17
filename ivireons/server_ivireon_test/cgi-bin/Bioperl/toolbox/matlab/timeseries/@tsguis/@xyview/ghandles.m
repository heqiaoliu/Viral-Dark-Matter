function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a freqview object.

%  Author(s): 
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:06:17 $
h = cat(3,[this.Curves(:); this.SelectionCurves(:)]);
function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a timeview object.

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:41:32 $

h = cat(3, [this.Curves(:); this.SelectionCurves(:); ...
    this.WatermarkCurves(:); this.SelectionPatch(:)]);

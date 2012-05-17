function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a freqview object.

%  Author(s): 
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:10:32 $
h = cat(3, [this.Curves(:);this.SelectionPatch(:);this.WatermarkCurves(:)]);
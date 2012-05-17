function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a nyquistview object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:38 $
h = cat(3,this.PosCurves,this.NegCurves,this.PosArrows,this.NegArrows);
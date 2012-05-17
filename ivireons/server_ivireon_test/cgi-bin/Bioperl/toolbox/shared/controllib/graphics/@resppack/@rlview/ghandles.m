function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a rlview object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:55 $
h = [this.Locus(:);this.SystemZero;this.SystemPole];
h = reshape(h,[1 1 length(h)]);

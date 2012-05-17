function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a TimeFinalValueView object.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:01:56 $

h = cat(3, this.Lines,this.VLines(:));

% REVISIT: Include line tips when handle(NaN) workaround removed

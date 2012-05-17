function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a StepRiseTimeView object.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:36 $

h = cat(3, this.HLines, this.UpperVLines, this.LowerVLines, this.Points);

% REVISIT: Include line tips when handle(NaN) workaround removed

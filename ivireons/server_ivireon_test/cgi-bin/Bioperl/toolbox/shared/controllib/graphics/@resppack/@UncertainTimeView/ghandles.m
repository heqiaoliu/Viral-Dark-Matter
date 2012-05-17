function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a UncertainTimeView object.

%  Author(s): Craig Buhr
%  Revised:
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:36:24 $

if strcmpi(this.UncertainType,'Bounds')
    h = cat(3, this.UncertainPatch);
else
    h = cat(3, this.UncertainLines);
end



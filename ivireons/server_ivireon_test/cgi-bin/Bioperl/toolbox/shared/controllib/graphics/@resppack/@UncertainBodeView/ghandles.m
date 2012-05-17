function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a UncertainTimeView object.

%  Author(s): Craig Buhr
%  Revised:
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:16 $

if strcmpi(this.UncertainType,'Bounds')
    h = cat(3, this.UncertainMagPatch,this.UncertainPhasePatch);
else
    h = cat(3, this.UncertainMagLines,this.UncertainPhaseLines);
end



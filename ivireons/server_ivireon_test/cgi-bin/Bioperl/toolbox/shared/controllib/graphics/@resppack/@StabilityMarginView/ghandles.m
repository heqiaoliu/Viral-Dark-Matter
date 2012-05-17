function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a StabilityMarginView object.

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:19 $
h_mag = [this.MagPoints; this.MagLines; this.MagCrossLines];
h_mag = reshape(h_mag,[1 1 1 1 length(h_mag)]);

h_phase = [this.PhasePoints; this.PhaseLines; this.PhaseCrossLines];  
h_phase = reshape(h_phase,[1 1 1 1 length(h_phase)]);

h = cat(3,h_mag,h_phase);
% REVISIT: Include line tips when handle(NaN) workaround removed
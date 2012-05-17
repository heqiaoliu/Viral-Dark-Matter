function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:46 $

this.CombType = s.CombType;
this.OrderMode2 = s.OrderMode2;
this.FrequencyConstraints = s.FrequencyConstraints;
this.BW  = s.BW;
this.Q   = s.Q;
this.GBW = s.GBW;
this.NumPeaksOrNotches = s.NumPeaksOrNotches;
this.ShelvingFilterOrder = s.ShelvingFilterOrder;

% [EOF]

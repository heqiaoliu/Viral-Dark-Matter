function s = thissaveobj(this, s)
%THISSAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:47 $

s.CombType = this.CombType;
s.BW  = this.BW;
s.Q   = this.Q;
s.GBW = this.GBW;
s.OrderMode2 = this.OrderMode2;
s.NumPeaksOrNotches = this.NumPeaksOrNotches;
s.ShelvingFilterOrder = this.ShelvingFilterOrder;
s.FrequencyConstraints = this.FrequencyConstraints;

% [EOF]

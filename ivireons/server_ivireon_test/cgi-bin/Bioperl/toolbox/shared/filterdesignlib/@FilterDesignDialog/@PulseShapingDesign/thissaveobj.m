function s = thissaveobj(this, s)
%THISSAVEOBJ Save this object.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:50 $

s.OrderMode2       = this.OrderMode2;
s.PulseShape       = this.PulseShape;
s.SamplesPerSymbol = this.SamplesPerSymbol;
s.NumberOfSymbols  = this.NumberOfSymbols;
s.Beta             = this.Beta;
s.Astop            = this.Astop;
s.AstopSQRT        = this.AstopSQRT;
s.BT               = this.BT;
s.FrequencyConstraints = this.FrequencyConstraints;
s.MagnitudeConstraints = this.MagnitudeConstraints;

% [EOF]

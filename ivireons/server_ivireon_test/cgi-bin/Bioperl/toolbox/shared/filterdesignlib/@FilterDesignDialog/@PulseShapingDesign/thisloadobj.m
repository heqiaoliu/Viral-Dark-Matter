function thisloadobj(this, s)
%THISLOADOBJ Load this object.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:49 $

this.OrderMode2       = s.OrderMode2;
this.PulseShape       = s.PulseShape;
this.SamplesPerSymbol = s.SamplesPerSymbol;
this.NumberOfSymbols  = s.NumberOfSymbols;
this.Beta             = s.Beta;
this.Astop            = s.Astop;
this.AstopSQRT        = s.AstopSQRT;
this.BT               = s.BT;
this.FrequencyConstraints = s.FrequencyConstraints;
this.MagnitudeConstraints = s.MagnitudeConstraints;

% [EOF]

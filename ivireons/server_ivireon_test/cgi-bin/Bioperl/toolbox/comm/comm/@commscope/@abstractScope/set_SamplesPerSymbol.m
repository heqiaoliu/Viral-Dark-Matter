function nSamps = set_SamplesPerSymbol(this, nSamps)
%SET_SAMPLESPERSYMBOL     Set SamplesPerSymbol.  This method can be overloaded.

%   @commscope/@abstractScope
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:18:00 $

% First set PrivSamplesPerSymbol
this.PrivSampsPerSym = nSamps;

% Setting nSamps changes SymbolRate
setPrivProp(this, 'SymbolRate', this.SamplingFrequency/nSamps);

% Reset
this.reset;

% Update plot if there is a scope
if ( this.isScopeAvailable )
    this.PrivUpdateAxes = 1;
    this.plot;
end

%-------------------------------------------------------------------------------
% [EOF]

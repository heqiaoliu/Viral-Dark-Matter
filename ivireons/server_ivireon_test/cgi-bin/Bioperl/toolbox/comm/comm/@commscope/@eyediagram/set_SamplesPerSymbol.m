function nSamps = set_SamplesPerSymbol(this, nSamps)
%SET_SAMPLESPERSYMBOL     Set SamplesPerSymbol.

%   @commscope/@eyediagram
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/06/08 15:52:29 $

% First set PrivSamplesPerSymbol
this.PrivSampsPerSym = nSamps;

% Setting nSamps changes SymbolRate
setPrivProp(this, 'SymbolRate', this.SamplingFrequency/nSamps);

% Update period
set(this, 'PrivPeriod', this.SymbolsPerTrace*nSamps);

% Reset
this.reset;

% Update plot if there is a scope
if ( this.isScopeAvailable )
    this.PrivUpdateAxes = 1;
    this.plot;
end

%-------------------------------------------------------------------------------
% [EOF]

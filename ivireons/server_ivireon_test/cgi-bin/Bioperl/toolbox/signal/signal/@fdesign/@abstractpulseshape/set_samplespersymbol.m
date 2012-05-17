function samplesPerSymbol = set_samplespersymbol(this, samplesPerSymbol)
%SET_SAMPLESPERSYMBOL PreSet function for the 'SamplesPerSymbol' property
%   OUT = SET_SAMPLESPERSYMBOL(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:00:22 $

set(this, 'privSamplesPerSymbol', samplesPerSymbol);

% If the SamplesPerSymbol property exists on the new specifications, set it.
if isprop(this.CurrentSpecs, 'SamplesPerSymbol')
    set(this.CurrentSpecs, 'SamplesPerSymbol', samplesPerSymbol);
end

% [EOF]

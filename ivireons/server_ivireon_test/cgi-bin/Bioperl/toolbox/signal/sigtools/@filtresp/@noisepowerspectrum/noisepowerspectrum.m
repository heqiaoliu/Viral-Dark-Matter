function h = noisepowerspectrum(varargin)
%NOISEPOWERSPECTRUM Construct a noisepowerspectrum object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/19 14:50:28 $

h = filtresp.noisepowerspectrum;

h.nlm_construct(varargin{:});

set(h, 'Name', 'Round-off Noise Power Spectrum');

% [EOF]

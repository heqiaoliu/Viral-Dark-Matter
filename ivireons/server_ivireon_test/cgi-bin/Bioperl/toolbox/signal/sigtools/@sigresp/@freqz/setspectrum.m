function spectrum = setspectrum(this, spectrum)
%SETSPECTRUM   Pre set function for the spectrum

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:42 $

this.privSpectrum = spectrum;

% Check metadata of new spectrum to update the units, i.e., update ylabel.
setvalidvalues(getparameter(this, getmagdisplaytag(this)), getylabels(this));

% [EOF]

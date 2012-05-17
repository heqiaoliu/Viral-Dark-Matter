function halfrange(this)
%HALFRANGE   Spectrum calculated over half the Nyquist interval.
%   HALFRANGE(H) converts the power spectrum specified by the data object
%   (<a href="matlab:help dspdata">dspdata</a>) H to a spectrum calculated over half the Nyquist interval.
%   The relevant properties such as, Frequencies and SpectrumRange, are
%   updated to reflect the new frequency range.
%
%   NOTE: No check is made to ensure that the data is symmetric, i.e., it
%   is assumed that the spectrum is from a real signal, and therefore only
%   half the data points are used.
%
%   See also DSPDATA, SPECTRUM.

%   Author(s): P. Pacheco
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:51 $

% Help for HALFRANGE method.

% [EOF]

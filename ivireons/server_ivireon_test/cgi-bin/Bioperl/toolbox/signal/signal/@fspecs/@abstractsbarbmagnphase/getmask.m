function [F, A] = getmask(this)
%GETMASK   Get the mask.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/10/14 16:27:49 $

nflag = get(this, 'NormalizedFrequency');
normalizefreq(this, true);

F = this.Frequencies;
A = this.FreqResponse;

normalizefreq(this, false);

% [EOF]

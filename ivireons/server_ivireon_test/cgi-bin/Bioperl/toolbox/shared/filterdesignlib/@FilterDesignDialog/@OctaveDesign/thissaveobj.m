function s = thissaveobj(this, s)
%THISSAVEOBJ Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:29:28 $

s.BandsPerOctave = this.BandsPerOctave;
s.F0             = this.F0;

% [EOF]

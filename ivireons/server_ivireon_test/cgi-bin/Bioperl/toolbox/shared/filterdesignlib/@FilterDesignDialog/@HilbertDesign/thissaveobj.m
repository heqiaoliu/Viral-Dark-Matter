function s = thissaveobj(this, s)
%THISSAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:23:40 $

s.TransitionWidth = this.TransitionWidth;
s.Apass           = this.Apass;

% [EOF]

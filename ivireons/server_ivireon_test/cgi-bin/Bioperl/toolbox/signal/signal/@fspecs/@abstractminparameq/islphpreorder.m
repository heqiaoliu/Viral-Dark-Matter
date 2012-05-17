function b = islphpreorder(this)
%ISLPHPREORDER True filter response is lowpass or highpass

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/04 23:21:26 $

b = this.F0==0 | this.F0==1;

% [EOF]

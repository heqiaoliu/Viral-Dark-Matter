function b = islphpreorder(this)
%ISLPHPREORDER True filter response is lowpass or highpass

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:31 $

b = this.F0==0 | this.F0==1;

% [EOF]

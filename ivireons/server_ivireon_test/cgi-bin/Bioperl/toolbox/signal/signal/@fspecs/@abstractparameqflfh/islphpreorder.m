function b = islphpreorder(this)
%ISLPHPREORDER True filter response is lowpass or highpass

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/04 23:21:28 $

b = this.Flow==0 | this.Fhigh==1;

% [EOF]

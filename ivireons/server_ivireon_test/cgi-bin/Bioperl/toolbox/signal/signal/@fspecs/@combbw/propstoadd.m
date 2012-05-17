function p = propstoadd(this)
%PROPSTOADD   Return the properties to add to the parent object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:31 $

%The first two properties are added here since they will be removed by the
%inherited thisprops2add methd
p = {'NormalizedFrequency','Fs','FilterOrder','BW'};

% [EOF]

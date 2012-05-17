function p = thispropstosync(this, p) %#ok<INUSL>
%THISPROPSTOSYNC   

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/31 23:27:10 $

% Exclude Astop
idx = strmatch('Astop', p);
p(idx) = [];

% [EOF]

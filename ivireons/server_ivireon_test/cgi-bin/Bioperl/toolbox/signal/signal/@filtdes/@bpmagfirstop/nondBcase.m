function nondBcase(h,d)
%nondBcase Handle the linear case.
%
% This should be a private method.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:02:03 $

convertmag(h,d,...
    {'Astop1', 'Astop2'},...
    {'Dstop1', 'Dstop2'},...
    {'stop', 'stop'},...
    @tolinear);

% [EOF]

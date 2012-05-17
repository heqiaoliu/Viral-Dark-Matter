function nondBcase(h,d)
%nondBcase Handle the linear case.
%
% This should be a private method.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:02:59 $

convertmag(h,d,...
    {'Apass1', 'Apass2'},...
    {'Dpass1', 'Dpass2'},...
    {'pass', 'pass'},...
    @tolinear);

% [EOF]

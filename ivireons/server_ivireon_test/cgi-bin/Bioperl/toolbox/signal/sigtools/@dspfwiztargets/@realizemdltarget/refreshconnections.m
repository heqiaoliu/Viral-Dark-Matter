function refreshconnections(hTar)
%REFRESHCONNECTIONS refresh system connections

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:56 $

sys = hTar.system;
oldpos = get_param(sys, 'Position');
set_param(sys, 'Position', oldpos + [0 -5 0 -5]);
set_param(sys, 'Position', oldpos);

% [EOF]

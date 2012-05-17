function fs = getfs(hFs, eventData)
%GETFS Returns the Sampling Frequency structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:25:35 $

fs = getfs(getcomponent(hFs, '-class', 'siggui.fsspecifier'));

% [EOF]

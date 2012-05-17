function hMgr = undomanager(limit)
%UNDOMANAGER Construct an undomanager object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/11/21 15:30:35 $

if nargin < 1, limit = 20; end

hMgr = siggui.undomanager;

set(hMgr, 'Limit', limit);
set(hMgr, 'Version', 1);

% [EOF]

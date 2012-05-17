function importBtnClicked(this)
%IMPORTBTNCLICKED Import button click callback

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:07:14 $

send(this, 'ImportBtnClicked', ...
    handle.EventData(this, 'ImportBtnClicked'));

% [EOF]

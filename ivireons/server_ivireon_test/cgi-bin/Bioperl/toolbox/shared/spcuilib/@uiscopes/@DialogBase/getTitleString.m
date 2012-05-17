function titleString = getTitleString(this)
%GETTITLESTRING Get the titleString.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/09/09 21:30:00 $

% Use full or short source name, depending on preference option:
titleString = getDialogTitle(this.hAppInst);

% [EOF]

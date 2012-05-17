function b = isDataEmpty(this)
%ISDATAEMPTY True if the object has empty data.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:49 $

b = isempty(this.DataHandler.UserData);

% [EOF]

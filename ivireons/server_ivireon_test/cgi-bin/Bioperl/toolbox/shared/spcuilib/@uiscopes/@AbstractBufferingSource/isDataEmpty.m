function b = isDataEmpty(this)
%ISDATAEMPTY True if the object is DataEmpty

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:46 $

dataBuffer = this.DataBuffer;
b = isempty(dataBuffer);

% [EOF]

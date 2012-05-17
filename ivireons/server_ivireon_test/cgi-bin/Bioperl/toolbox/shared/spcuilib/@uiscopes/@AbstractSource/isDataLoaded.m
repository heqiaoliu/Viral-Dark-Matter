function b = isDataLoaded(this)
%ISDATALOADED True if the object is DataLoaded

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:44:05 $

b = ~isDataEmpty(this);

% [EOF]

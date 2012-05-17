function b = isminorder(this, laState)
%ISMINORDER True if the object is minorder

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 06:57:26 $

if nargin > 1 && ~isempty(laState)
    source = laState;
else
    source = this;
end

b = strcmpi(source.OrderMode2, 'minimum');

% [EOF]

function b = isminorder(this, laState)
%ISMINORDER   True if the object is minorder.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:24:36 $

if nargin > 1 && ~isempty(laState)
    source = laState;
else
    source = this;
end

b = strcmpi(source.OrderMode, 'minimum');

% [EOF]

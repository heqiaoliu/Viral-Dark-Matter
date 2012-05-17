function value = getValue(this, tag)
%GETVALUE Get the value for the specified tag.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:39 $

value = get(findProp(this, tag), 'Value');

% [EOF]

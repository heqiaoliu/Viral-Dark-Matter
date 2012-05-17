function s = saveobj(this)
%SAVEOBJ  Save this object.
%   OUT = SAVEOBJ(ARGS) <long description>

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:44:54 $

s.class   = class(this);

% Save all of the public properties.
s = setstructfields(s, get(this));

% [EOF]

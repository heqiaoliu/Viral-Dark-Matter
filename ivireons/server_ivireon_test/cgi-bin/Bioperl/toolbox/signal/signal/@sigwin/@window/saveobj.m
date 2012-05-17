function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:20:13 $

% Get all the public properties.
s = rmfield(get(this), 'Name');

% Get the class.
s.class = class(this);

% [EOF]

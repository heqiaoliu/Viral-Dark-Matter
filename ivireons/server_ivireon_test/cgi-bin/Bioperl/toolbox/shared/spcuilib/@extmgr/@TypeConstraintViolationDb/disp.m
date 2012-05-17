function disp(this)
%DISP Display TypeConstraintViolationDb object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:42 $

fprintf('  Object of type %s\n', class(this));

% No local properties currently - suppress this display:
% get(this)

disp(messages(this));

% [EOF]

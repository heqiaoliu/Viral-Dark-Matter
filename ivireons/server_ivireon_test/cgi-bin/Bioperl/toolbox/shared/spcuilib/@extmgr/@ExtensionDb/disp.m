function disp(this)
% Display ExtensionDb object

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:46:25 $

fprintf('Object of class "%s"\n', class(this))
get(this)

fprintf('Extension children:\n\n');
iterator.visitImmediateChildren(this,@disp);

% [EOF]

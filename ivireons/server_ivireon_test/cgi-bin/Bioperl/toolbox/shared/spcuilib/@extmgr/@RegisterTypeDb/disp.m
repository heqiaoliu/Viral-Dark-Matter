function disp(this)
%DISP Display RegisterTypeDb object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:26 $

fprintf('  Object of type %s\n', class(this));

% No local properties currently - suppress this display:
% get(this)

N=iterator.numImmediateChildren(this);
if N==0
    fprintf('  No types registered.\n');
else
    fprintf('  RegisterType children: (%d total)\n', N);
    iterator.visitImmediateChildren(this,@disp);
end

% [EOF]

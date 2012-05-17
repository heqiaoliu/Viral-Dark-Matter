function disp(hGroup)
%DISP Display key group object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:00 $

fprintf('KeyGroup object "%s" (%d children)\n', ...
    hGroup.Name, iterator.numImmediateChildren(hGroup) );

% Display properties
fprintf('  KeyGroup Properties:\n');
get(hGroup)

% Display children
fprintf('  KeyGroup Children:\n');
iterator.visitImmediateChildren(hGroup,@disp);


% [EOF]

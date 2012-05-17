function disp(this)
%DISP Display PropertyDb object.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/10/29 16:08:11 $

% No local properties currently - suppress this display:
% get(this)

N=iterator.numImmediateChildren(this);
if N==0
    fprintf('  No properties specified.\n');
else
    iterator.visitImmediateChildren(this,@disp);
end

if strcmpi(get(0, 'FormatSpacing'), 'loose')
    fprintf('\n');
end

% [EOF]

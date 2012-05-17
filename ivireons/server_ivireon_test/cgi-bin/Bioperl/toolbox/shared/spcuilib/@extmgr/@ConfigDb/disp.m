function disp(h,short)
%DISP Display extension property (Property)

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:45:38 $

disp('Object of class ConfigDb:');
fprintf('  Name: %s\n', h.Name);
N=iterator.numImmediateChildren(h);
if N==0
    fprintf('  No extensions configured.\n');
else
    fprintf('  Extensions: (%d configured)\n', N);
    if nargin<2, short=false; end
    if ~short
        iterator.visitImmediateChildren(h,@disp);
    end
end

% [EOF]

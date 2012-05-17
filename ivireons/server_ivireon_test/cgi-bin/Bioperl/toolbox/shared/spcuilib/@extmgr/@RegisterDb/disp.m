function disp(this)
%DISP Display Extension Registration Database object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/05/23 19:03:43 $

indx = 1;

% List out registered extensions
%
fprintf('Object of class "%s"\nExtension registration database\n', class(this));
iterator.visitImmediateChildren(this, @(hChild) lclChildDisp(hChild));

fprintf('\nPublic properties:\n');
get(this)

%% ------------------------------------------------------------------------
    function lclChildDisp(hChild)

        fprintf('--- Extension #%d\n', indx);
        fprintf('     Type: %s\n', hChild.Type);
        fprintf('     Name: %s\n', hChild.Name);
        fprintf('    Class: %s\n', hChild.Class);
        fprintf('    Descr: %s\n', hChild.Description);
        fprintf('     File: %s\n', hChild.File);
        fprintf('    Order: %d\n', hChild.Order);
        fprintf('  Depends: %s\n', getDependsStr(hChild));
        fprintf('\n');

        indx = indx + 1;
    end
end

% [EOF]

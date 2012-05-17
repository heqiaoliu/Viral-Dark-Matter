function disp(this)
%DISP Display extension driver (Driver)

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/05/23 19:03:28 $

disp(get(this))

disp('Enabled extensions');

iterator.visitImmediateChildren(this.ConfigDb, @(hConfig) lclDispName(hConfig));

if strcmpi(get(0, 'FormatSpacing'), 'loose')
    disp(' ');
end

% -------------------------------------------------------------------------
function lclDispName(hConfig)

if hConfig.Enable
    disp(sprintf('    %s:%s', hConfig.Type, hConfig.Name));
end

% [EOF]

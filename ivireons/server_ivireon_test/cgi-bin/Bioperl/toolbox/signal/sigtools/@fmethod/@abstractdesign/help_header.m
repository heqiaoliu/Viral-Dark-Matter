function help_header(this, method, description, type)
%HELP_HEADER   Generic help.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:38:21 $

disp(sprintf('%s\n%s', ...
    sprintf(' DESIGN Design a %s %s filter.', description, type), ...
    sprintf('    HD = DESIGN(D, ''%s'') designs a %s filter specified by the\n    FDESIGN object D.', ...
    method, description)));
disp(' ');

validstructs = getvalidstructs(this);

helpstr = sprintf('    HD = DESIGN(..., ''FilterStructure'', STRUCTURE) returns a filter with the\n');
helpstr = sprintf('%s    structure STRUCTURE.  STRUCTURE is ''%s'' by default and can be any of\n', ...
    helpstr, this.FilterStructure);
helpstr = sprintf('%s    the following:', helpstr);
helpstr = sprintf('%s\n', helpstr);
for indx = 1:length(validstructs)
    helpstr = sprintf('%s\n    ''%s''', helpstr, validstructs{indx});
end

disp(helpstr);

disp(' ');

% [EOF]

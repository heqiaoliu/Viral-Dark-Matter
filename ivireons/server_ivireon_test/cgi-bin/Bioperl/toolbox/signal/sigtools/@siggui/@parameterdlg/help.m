function help(hObj)
%HELP Help for the dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:12:17 $

str = get(hObj, 'HelpLocation');

if isempty(str),
    doc signal
else
    helpview(str{:});
end

% [EOF]

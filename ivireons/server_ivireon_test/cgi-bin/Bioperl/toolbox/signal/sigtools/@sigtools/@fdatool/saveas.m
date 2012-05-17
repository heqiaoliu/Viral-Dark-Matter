function success = saveas(hFDA, file)
%SAVEAS Save the file

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2007/12/14 15:21:21 $

success = false;

% If a file isn't specified, bring up the dialog
if nargin == 1,
    file = get(hFDA, 'FileName');
    [filename,pathname] = uiputfile('*.fda', 'Save Filter Design Session', file);
    file = [pathname filename];
end

% Don't save if filename is 0
if filename ~= 0,
    success = save(hFDA, file);
end

% [EOF]

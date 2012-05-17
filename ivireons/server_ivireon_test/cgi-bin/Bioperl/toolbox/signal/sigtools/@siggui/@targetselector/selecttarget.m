function selecttarget(hTS)
%SELECTTARGET Select the target from a dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/13 00:26:47 $

try
    [bdnum,prnum] = boardprocsel;
    set(hTS, 'BoardNumber', sprintf('%d', bdnum));
    set(hTS, 'ProcessorNumber', sprintf('%d', prnum));
catch
    error('%s\n%s', ...
        'Unable to run board selection utility.', ...
        'Board and processor must be entered manually.');
end

% [EOF]

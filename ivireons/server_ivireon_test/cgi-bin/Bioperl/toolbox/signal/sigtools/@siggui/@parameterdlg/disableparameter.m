function disableparameter(hDlg, tag)
%DISABLEPARAMETER Disable a parameter by it's tag

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:19:05 $

error(nargchk(2,2,nargin,'struct'));

if ~ischar(tag),
    error(generatemsgid('MustBeAString'),'The tag of the parameter must be a string.');
end

tags = get(hDlg.Parameter, 'Tag');

indx = find(strcmpi(tag, tags));

if isempty(indx),
    error(generatemsgid('NotSupported'),'No parameter with that tag found.');
end

dparams = get(hDlg, 'DisabledParameters');

% Only use store the string if it is not already in the vector.
if isempty(find(strcmpi(tag, dparams))),
    dparams = {dparams{:}, tag};
end

set(hDlg, 'DisabledParameters', dparams);

% [EOF]

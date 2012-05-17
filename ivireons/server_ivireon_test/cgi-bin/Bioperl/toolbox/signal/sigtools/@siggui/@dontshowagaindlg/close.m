function close(this)
%CLOSE   Close the dialog and save the preference.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:22:52 $

if ~isempty(this.PrefTag)
    if strcmpi(this.DontShowAgain, 'on'),
        setpref('dontshowmeagain', this.PrefTag, true);
    end
end

if isrendered(this), unrender(this); end

% [EOF]

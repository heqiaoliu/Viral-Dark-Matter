function bool = need2show(this)
%NEED2SHOW   Returns true if the dialog should be shown.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:22:54 $

if isempty(this.PrefTag),
    bool = true;
else
    bool = ~getpref('dontshowmeagain', this.PrefTag, false);
end

% [EOF]

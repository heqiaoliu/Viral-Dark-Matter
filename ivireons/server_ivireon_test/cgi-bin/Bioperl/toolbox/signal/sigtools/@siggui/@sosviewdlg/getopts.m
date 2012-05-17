function opts = getopts(this, opts)
%GETOPTS   Get the opts.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/10/18 03:29:00 $

% If an options is passed in use it, otherwise create a new one.
if nargin < 2
    opts = dspopts.sosview;
end
if isempty(opts)
    opts = dspopts.sosview;
end

% Convert the 'on/off' property to a boolean.
if strcmpi(this.SecondaryScaling, 'on')
    ss = true;
else
    ss = false;
end

% Set up the options dialog.
set(opts, 'View', this.ViewType, ...
    'UserDefinedSections', evalin('base', this.Custom), ...
    'SecondaryScaling', ss);

% [EOF]

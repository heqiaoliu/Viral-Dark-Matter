function help(this)
%HELP   Generic help for butterworth designs.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:49:39 $

help_butter(this);
if isfdtbxinstalled
    help_sosscale(this);
end
help_examples(this);

% [EOF]

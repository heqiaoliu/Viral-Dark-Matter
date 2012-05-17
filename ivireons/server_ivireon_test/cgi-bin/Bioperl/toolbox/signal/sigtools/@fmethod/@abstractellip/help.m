function help(this)
%HELP   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:49:44 $

help_ellip(this);
if isfdtbxinstalled
    help_sosscale(this);
end
help_examples(this);

% [EOF]

function help(this)
%HELP   

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:31:18 $

help_header(this, 'butter', 'generalized Butterworth', 'IIR');
if isfdtbxinstalled
    help_sosscale(this);
end
help_examples(this);

%[EOF]  
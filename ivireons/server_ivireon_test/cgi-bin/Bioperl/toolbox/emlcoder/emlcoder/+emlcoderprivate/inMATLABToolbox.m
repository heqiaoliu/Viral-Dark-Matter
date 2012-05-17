function b = inMATLABToolbox(path)
% Return true if the path resides under MATLABROOT/toolbox.  These are
% shipping directories that users should not modify.

%   Copyright 2009 The MathWorks, Inc.

mrt = [matlabroot filesep 'toolbox' ];

p = fullfile(path);
if ~isempty(strfind(p,mrt))
    b = true;
else
    b = false;
end
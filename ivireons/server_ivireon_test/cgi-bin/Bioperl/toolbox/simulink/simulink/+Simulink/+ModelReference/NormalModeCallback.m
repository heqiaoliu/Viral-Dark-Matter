% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

classdef NormalModeCallback < handle
    methods (Abstract)
        runCallback(this, blockpath, referencedModelName)
    end
end

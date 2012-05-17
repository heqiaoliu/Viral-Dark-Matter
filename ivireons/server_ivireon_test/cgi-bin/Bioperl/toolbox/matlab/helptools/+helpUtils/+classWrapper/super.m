classdef super < handle
    methods (Abstract)
        b = hasClassHelp(cw);
        classInfo = getPropertyHelpFile(cw);
    end

    methods (Abstract, Access=protected)
        classInfo = getClassHelpFile(cw);
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/01/15 18:54:33 $

classdef raw < handle
    properties (SetAccess=protected, GetAccess=protected)
        isUnspecifiedConstructor = false;
        implementor = false;
    end

    methods (Abstract)
        classInfo = getConstructor(cw, justChecking);
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2008/01/15 18:54:30 $

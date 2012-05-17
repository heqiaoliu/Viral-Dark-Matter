classdef CursorType < int32

    % Copyright 2009-2010 The MathWorks, Inc.

    enumeration
        Select(0)
        ZoomInX(1)
        ZoomInY(2)
        ZoomInXY(3)
        ZoomOut(4)
        Pan(5)
        DataCursor(6)
    end
end

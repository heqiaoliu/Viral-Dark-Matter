classdef CdRequestMode < Simulink.IntEnumType

%   Copyright 2008-2010 The MathWorks, Inc.

    enumeration     
        EMPTY(-2),
        DISCINSERT(-1),
        STOP(0),
        PLAY(1),
        REW(3),
        FF(4),
        EJECT(5)
    end    
end

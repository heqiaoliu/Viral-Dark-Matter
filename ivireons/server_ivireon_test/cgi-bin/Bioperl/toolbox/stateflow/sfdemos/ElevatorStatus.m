classdef (Enumeration) ElevatorStatus < Simulink.IntEnumType
% ELEVATORSTATUS - Enumeration class for the status of an elevator car in
% the sf_elevator demo.

%   Copyright 2010 The MathWorks, Inc.
    enumeration
        IDLE(0)
        BUSY(1)
        EMERG(2)
    end 
end
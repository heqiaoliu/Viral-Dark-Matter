classdef sf_aircraft_ModeType < Simulink.IntEnumType

%   Copyright 2009-2010 The MathWorks, Inc.

  enumeration
    Isolated(0)
    Off(1)
    Passive(2)
    Standby(3)
    Active(4)
  end
end

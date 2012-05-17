classdef SlDemoRangeCheck < Simulink.IntEnumType
% SLDEMORANGECHECK  Enumeration class for sldemo_mdlref_datamngt.mdl

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $ $Date: 2010/05/20 03:16:19 $

  enumeration
    UpperLimit(1)
    InRange(0)
    LowerLimit(-1)
  end
  
  methods (Static)
    function retVal = addClassNameToEnumNames()
      retVal = true;
    end
      
    function retVal = getDefaultValue()
      retVal = SlDemoRangeCheck.InRange;
    end
  end
end

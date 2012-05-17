%Coverage API

%   Copyright 2009 The MathWorks, Inc.

classdef CoverageAPI < handle
  properties
  end
  methods
  end
  methods(Static)
      description  = getCoverageDef(blockH, cvmetric)
      compileForCoverage(blockH)
  end
end

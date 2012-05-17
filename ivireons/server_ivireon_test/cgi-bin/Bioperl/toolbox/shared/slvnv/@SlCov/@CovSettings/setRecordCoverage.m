 function setRecordCoverage(this, value)

%   Copyright 2009-2010 The MathWorks, Inc.

    this.recordCoverage = value;
    SlCov.CovSettings.mdlRefRecordCoverageUpdate(this);

 function setCumulativeReport(this, value)

%   Copyright 2010 The MathWorks, Inc.

    if  value
        this.covCumulativeReport =  'Slvnv:simcoverage:covCumulativeReport1';
    else
        this.covCumulativeReport =  'Slvnv:simcoverage:covCumulativeReport2';
    end

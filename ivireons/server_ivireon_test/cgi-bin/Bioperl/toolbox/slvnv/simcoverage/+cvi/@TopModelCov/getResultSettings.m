function getResultSettings(this)

%   Copyright 2008 The MathWorks, Inc.

   
    this.resultSettings = cvi.ReportUtils.getAllOptions(this.topModelH);
    this.resultSettings.topModelName = get_param(this.topModelH, 'name');
    this.resultSettings.cumulativeReport = false; 

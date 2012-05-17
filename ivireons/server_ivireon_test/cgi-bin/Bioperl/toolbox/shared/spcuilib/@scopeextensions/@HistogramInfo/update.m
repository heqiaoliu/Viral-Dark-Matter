function update(this)
% UPDATEINFO Update the histogram information dialog.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $     $Date: 2010/03/31 18:41:23 $

if ~isempty(this.hAppInst.Visual)
  data = this.hAppInst.Visual.HistData;

  if isempty(data)
    this.DataType = '';
    this.AbsMin = '';
    this.Min = '';
    this.Max = '';
    this.Range = '';
    this.NumZeros = '';
    this.Mean = '';
    this.StdDev = '';
    this.PercentOverflw = '';
    this.PercentUnderflw = '';
    this.NumSamples = '';
  else
    this.DataType = strtrim(getDataTypes(this.hAppInst.DataSource, 1));
    this.AbsMin = strtrim(sprintf('%5.3g',data.minAbs));
    this.Min = strtrim(sprintf('%5.3g',data.min));
    this.Max = strtrim(sprintf('%5.3g',data.max));
    this.Mean = strtrim(sprintf('%5.3g',data.Mean));
    this.StdDev = strtrim(sprintf('%5.3g',data.StdDev));
    this.NumZeros = strtrim(sprintf('%5.3g',data.numZeros));
    this.NumSamples = strtrim(sprintf('%5.3g',data.numSamples));
    this.PercentOverflw = strtrim(sprintf('%5.3g',data.ovfl));
    this.PercentUnderflw = strtrim(sprintf('%5.3g',data.uflw));
    this.TitlePrefix  = getTitleString(this);
  end
    % Force an update because the histogram data is created after the
    % call to refresh the dialog.
    if ~isempty(this.Dialog)
        refresh(this.Dialog);
    end
 end


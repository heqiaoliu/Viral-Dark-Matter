function applySigmaPlotOpts(this,h,varargin)
%APPLYSIGMAPLOTOPTS  set Sigma plot properties

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:18:01 $

if isempty(varargin) 
    allflag = false;
else
    allflag = varargin{1};
end

% Apply Frequency Properties
h.AxesGrid.XUnits = this.FreqUnits;
h.AxesGrid.XScale = this.FreqScale;

% Apply Magnitude Properties
h.AxesGrid.YUnits = this.MagUnits;
h.AxesGrid.YScale = this.MagScale;

if allflag
   applyRespPlotOpts(this,h,allflag);
end
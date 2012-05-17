function applyNyquistPlotOpts(this,h,varargin)
%APPLYNYQUISTPLOTOPTS  set Nyquist plot properties

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:37 $

if isempty(varargin) 
    allflag = false;
else
    allflag = varargin{1};
end

h.FrequencyUnits = this.FreqUnits;
h.MagnitudeUnits = this.MagUnits;
h.PhaseUnits = this.PhaseUnits;
h.ShowFullContour = this.ShowFullContour;



if allflag
   applyRespPlotOpts(this,h,allflag);
end
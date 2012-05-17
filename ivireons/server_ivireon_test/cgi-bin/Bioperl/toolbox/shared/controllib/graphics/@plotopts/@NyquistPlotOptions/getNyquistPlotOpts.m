function getNyquistPlotOpts(this,h,varargin)
%GETNYQUISTPLOTOPTS Gets plot options of @nyquistplot h  

%  Author(s): C. Buhr
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:38 $

if isempty(varargin) 
   allflag = false;
else
    allflag = varargin{1};
end


this.FreqUnits = h.FrequencyUnits;
this.MagUnits = h.MagnitudeUnits;
this.PhaseUnits = h.PhaseUnits;
this.ShowFullContour = h.ShowFullContour;



if allflag
    getRespPlotOpts(this,h,allflag);
end
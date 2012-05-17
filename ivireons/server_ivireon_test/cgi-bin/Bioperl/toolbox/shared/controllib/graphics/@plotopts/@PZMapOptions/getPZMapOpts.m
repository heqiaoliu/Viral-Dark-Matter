function getPZMapOpts(this,h,varargin)
%GETPZMAPPLOTOPTS Gets plot options of @pzplot h 

%  Author(s): C. Buhr
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:43 $

if isempty(varargin) 
   allflag = false;
else
    allflag = varargin{1};
end


this.FreqUnits = h.FrequencyUnits;

                 
if allflag
    getRespPlotOpts(this,h,allflag);
end
function applyPZMapOpts(this,h,varargin)
%APPLYPZMAPOPTS  set pzplot properties

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:42 $

if isempty(varargin) 
    allflag = false;
else
    allflag = varargin{1};
end


h.FrequencyUnits = this.FreqUnits;
      

if allflag
   applyRespPlotOpts(this,h,allflag);
end
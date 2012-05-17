function applyNicholsPlotOpts(this,h,varargin)
%APPLYNICHOLSPLOTOPTS  set nicholsplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:31 $

if isempty(varargin) 
    allflag = false;
else
    allflag = varargin{1};
end

h.FrequencyUnits = this.FreqUnits;
     
h.AxesGrid.XUnits = this.PhaseUnits;

if strcmp(this.PhaseWrapping,'off')
    Options.UnwrapPhase = 'on';
else
    Options.UnwrapPhase = 'off';
end

if strcmpi(this.MagLowerLimMode,'auto')
    Options.MinGainLimit.Enable = 'off';
else
    Options.MinGainLimit.Enable = 'on';
end
Options.MinGainLimit.MinGain = this.MagLowerLim;

Options.ComparePhase = struct( ...
    'Enable',this.PhaseMatching, ...
    'Freq', this.PhaseMatchingFreq, ...
    'Phase', this.PhaseMatchingValue);

h.Options = Options;

if allflag
   applyRespPlotOpts(this,h,allflag);
end
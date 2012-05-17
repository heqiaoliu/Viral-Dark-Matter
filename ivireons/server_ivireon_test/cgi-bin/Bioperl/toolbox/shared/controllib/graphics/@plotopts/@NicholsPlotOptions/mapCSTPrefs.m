function mapCSTPrefs(this,varargin)
%MAPCSTPREFS for NicholsPlotOptions

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:33 $

if isempty(varargin)
    CSTPrefs = cstprefs.tbxprefs;
else
    CSTPrefs = varargin{1};
end

mapCSTPrefs2RespPlotOpts(this,CSTPrefs);
mapCSTPrefs2PlotOpts(this,CSTPrefs);

this.FreqUnits = CSTPrefs.FrequencyUnits; 
this.PhaseUnits = CSTPrefs.PhaseUnits; 

if strcmpi(CSTPrefs.UnwrapPhase, 'off')
    this.PhaseWrapping = 'on';
else
    this.PhaseWrapping = 'off';
end

if strcmp(CSTPrefs.MinGainLimit.Enable,'on')
    this.MagLowerLimMode = 'manual';
else
    this.MagLowerLimMode = 'auto';
end
% convert to dB since Nichols chart only allows dB units
this.MagLowerLim = unitconv(CSTPrefs.MinGainLimit.MinGain,CSTPrefs.MagnitudeUnits,'dB');

this.PhaseMatching = CSTPrefs.ComparePhase.Enable;
this.PhaseMatchingFreq = CSTPrefs.ComparePhase.Freq;
this.PhaseMatchingValue = CSTPrefs.ComparePhase.Phase;

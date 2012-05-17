function opt = simViewOptions(varargin)
%SIMVIEWOPTIONS Set options for FRESTIMATE simulation results viewer.
%
% OPT=FREST.SIMVIEWOPTIONS creates a simview options object with the default 
% settings. The variable, OPT, is passed to the function FREST.SIMVIEW to
% specify the options for FRESTIMATE simulation results viewer.
%
% OPT=FREST.SIMVIEWOPTIONS('Property1','Value1','Property2','Value2',...) creates a 
% simview options object, OPT, in which the option given by Property1 is
% set to the value given in Value1, the option given by Property2 is set to
% the value given in Value2, etc.
% 
% The following options can be set with frest.simViewOptions:
%
%    Options for time response plot:
%      TimeVisible       [on|off]     Time plot visibility
%      TimeGrid          [off|on]     Show/hide grid in time plot
%
%    Options for spectrum plot:
%      SpectrumVisible   [on|off]      Spectrum plot visibility
%      SpectrumGrid      [off|on]      Show/hide grid in spectrum plot
%      SpectrumAmpUnits  [abs|dB]      Amplitude units in spectrum plot
%      SpectrumFreqUnits [rad/s|Hz]    Frequency units in spectrum plot
%      SpectrumAmpScale  [linear|log]  Amplitude scale in spectrum plot
%      SpectrumFreqScale [linear|log]  Frequency scale in spectrum plot
%
%    Options for summary plot:
%      SummaryVisible         [on|off]      Summary plot visibility
%      SummaryMagVisible      [on|off]      Magnitude plot visibility in summary plot
%      SummaryPhaseVisible    [off|on]      Phase plot visibility in summary plot
%      SummaryGrid            [off|on]      Show/hide grid in summary plot
%      SummaryMagUnits        [dB|abs]      Magnitude units in summary plot 
%      SummaryFreqUnits       [rad/s|Hz]    Frequency units in summary plot 
%      SummaryPhaseUnits      [deg|rad]     Phase units in summary plot 
%      SummaryMagScale        [linear|log]  Magnitude scale in summary plot
%      SummaryFreqScale       [log|linear]  Frequency scale in summary plot
%      SummaryPhaseScale      [linear|log]  Phase scale in summary plot
%      SummaryPhaseWrapping   [off|on]      Phase unwrapping in summary plot
%
%
%   See also FREST.SIMVIEW, FRESTIMATE

%  Author(s):  Erman Korkut 12-Mar-2009
%  Revised:
% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:37 $

% Create the object
opt = frestviews.SimviewOptions(varargin{:});
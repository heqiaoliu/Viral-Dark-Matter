function p = bodeoptions(varargin)
%BODEOPTIONS Creates option list for Bode plot.
%
%   P = BODEOPTIONS returns the default options for Bode plots. This
%   list of options allows you to customize the Bode plot appearance
%   from the command line. For example
%         P = bodeoptions;
%         % Set phase visibility to off and frequency units to Hz in options 
%         P.PhaseVisible = 'off'; 
%         P.FreqUnits = 'Hz'; 
%         % Create plot with the options specified by P
%         h = bodeplot(tf(1,[1,1]),P);
%   creates a Bode plot with the phase plot visibility turned off and the
%   frequency units in Hz. 
%
%   P = BODEOPTIONS('cstprefs') initializes the plot options with the
%   Control System Toolbox preferences.
%
%   Available options include:
%      Title, XLabel, YLabel         Label text and style
%      TickLabel                     Tick label style
%      Grid   [off|on]               Show or hide the grid 
%      XlimMode, YlimMode            Limit modes
%      Xlim, Ylim                    Axes limits
%      IOGrouping                    Grouping of input-output pairs
%         [none|inputs|output|all] 
%      InputLabels, OutputLabels     Input and output label styles
%      InputVisible, OutputVisible   Visibility of input and output
%                                    channels
%      FreqUnits [Hz|rad/s]          Frequency Units
%      FreqScale [linear|log]        Frequency Scale
%      MagUnits [dB|abs]             Magnitude Units
%      MagScale [linear|log]         Magnitude Scale
%      MagVisible [on|off]           Magnitude plot visibility
%      MagLowerLimMode [auto|manual] Enables a lower magnitude limit
%      MagLowerLim                   Specifies the lower magnitude limit
%      PhaseUnits [deg|rad]          Phase units
%      PhaseVisible [on|off]         Phase plot visibility
%      PhaseWrapping [on|off]        Enables phase wrapping
%      PhaseMatching [on|off]        Enables phase matching 
%      PhaseMatchingFreq             Frequency for matching phase
%      PhaseMatchingValue            The value to make the phase responses 
%                                    close to
%
%   See also LTI/BODEPLOT, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $   $Date: 2009/11/09 16:22:15 $

p = plotopts.BodePlotOptions(varargin{:});
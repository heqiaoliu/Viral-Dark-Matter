function p = nyquistoptions(varargin)
%NYQUISTOPTIONS Creates option list for Nyquist plot.
%
%   P = NYQUISTOPTIONS returns the default options for Nyquist plots. This
%   list of options allows you to customize the Nyquist plot appearance
%   from the command line. For example
%         P = nyquistoptions;
%         % Set option to show the full contour 
%         P.ShowFullContour = 'on'; 
%         % Create plot with the options specified by P
%         h = nyquistplot(tf(1,[1,.2,1]),P);
%   creates a Nyquist plot with the full contour shown (the response for
%   both positive and negative frequencies).
%
%   P = NYQUISTOPTIONS('cstprefs') initializes the plot options with the
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
%      MagUnits [dB|abs]             Magnitude Units
%      PhaseUnits [deg|rad]          Phase units
%      ShowFullContour [on|off]      Show response for negative frequencies
%
%   See also LTI/NYQUISTPLOT, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $   $Date: 2006/12/27 20:33:34 $

p = plotopts.NyquistPlotOptions(varargin{:});
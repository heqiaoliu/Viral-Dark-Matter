function p = sigmaoptions(varargin)
%SIGMAOPTIONS Creates option list for singular value plots.
%
%   P = SIGMAOPTIONS returns the default options for singular value plots.
%   This list of options allows you to customize the singular value plot
%   appearance from the command line. For example
%         P = sigmaoptions;
%         % Set the frequency units to Hz in options 
%         P.FreqUnits = 'Hz'; 
%         % Create plot with the options specified by P
%         h = sigmaplot(rss(2,2,3),P);
%   creates a singular value plot with the frequency units in Hz. 
%
%   P = SIGMAOPTIONS('cstprefs') initializes the plot options with the
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
%
%   See also LTI/SIGMAPLOT, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $   $Date: 2006/12/27 20:33:38 $

p = plotopts.SigmaPlotOptions(varargin{:});
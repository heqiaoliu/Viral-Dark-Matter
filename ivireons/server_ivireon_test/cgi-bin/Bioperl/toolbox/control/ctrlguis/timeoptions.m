function p = timeoptions(varargin)
%TIMEOPTIONS Creates option list for time plot.
%
%   P = TIMEOPTIONS the default options for time plots (lsim, step,
%   initial, impulse). This list of options allows you to customize the
%   time plot appearance from the command line. For example
%         P = timeoptions;
%         % Set normalize response to on in options 
%         P.Normalize = 'on'; 
%         % Create plot with the options specified by P
%         h = stepplot(tf(10,[1,1]),tf(5,[1,5]),P); 
%   creates a step plot with the responses normalized.
%
%   P = TIMEOPTIONS('cstprefs') initializes the plot options with the
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
%      Normalize [on|off]            Normalize repsonses
%      SettleTimeThreshold           Settling time threshold
%      RiseTimeLimits                Rise time limits
%
%   See also LTI/LSIMPLOT, LTI/INITIALPLOT, LTI/IMPULSEPLOT, LTI/STEPPLOT,
%   WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $   $Date: 2006/12/27 20:33:39 $

p = plotopts.TimePlotOptions(varargin{:});
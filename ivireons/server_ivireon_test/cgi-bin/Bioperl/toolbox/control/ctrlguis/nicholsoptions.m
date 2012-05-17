function p = nicholsoptions(varargin)
%NICHOLSOPTIONS Creates option list for Nichols plot.
%
%   P = NICHOLSOPTIONS returns the default options for Nichols plots. This
%   list of options allows you to customize the nichols plot appearance
%   from the command line.  For example
%         P = nicholsoptions;
%         % Set phase units to radians and grid to on in options 
%         P.PhaseUnits = 'rad'; 
%         P.Grid = 'on';
%         % Create plot with the options specified by P
%         h = nicholsplot(tf(1,[1,.2,1,0]),P);
%   creates a Nichols plot with the phase units in radians and the grid
%   turned on.
%
%   P = NICHOLSOPTIONS('cstprefs') initializes the plot options with the
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
%      MagLowerLimMode [auto|manual] Enables a lower magnitude limit
%      MagLowerLim                   Specifies the lower magnitude limit
%      PhaseUnits [deg|rad]          Phase units
%      PhaseWrapping [on|off]        Enables phase wrapping
%      PhaseMatching [on|off]        Enables phase matching 
%      PhaseMatchingFreq             Frequency for matching phase
%      PhaseMatchingValue            The value to make the phase repsonses 
%                                    close to
%
%   See also LTI/NICHOLSPLOT, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $   $Date: 2006/12/27 20:33:33 $

p = plotopts.NicholsPlotOptions(varargin{:});
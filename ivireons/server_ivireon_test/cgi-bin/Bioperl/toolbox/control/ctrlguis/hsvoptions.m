function p = hsvoptions(varargin)
%HSVOPTIONS  Creates option list for Hankel singular value plot.
%
%   P = HSVOPTIONS returns the default options for Hankel singular value
%   plots. This list of options allows you to customize the Hankel singular
%   value plot appearance from the command line. For example
%         P = hsvoptions;
%         % Set the Y axis scale to linear in options 
%         P.YScale = 'linear'; 
%         % Create plot with the options specified by P
%         h = hsvplot(rss(2,2,3),P);
%   creates a Hankel singular value plot with a linear scale for the Y axis.  
%
%   P = HSVOPTIONS('cstpref') initializes the plot options with 
%   the Control System Toolbox preferences.
%
%   Available options include:
%      Title, XLabel, YLabel    Label text and style
%      TickLabel                Tick label style
%      Grid   [off|on]          Show or hide the grid 
%      XlimMode, YlimMode       Limit modes
%      Xlim, Ylim               Axes limits
%      YScale [linear|log]      Scale for Y axis
%      AbsTol, RelTol, Offset   Parameters for the Hankel singular
%                               value computation (used only for
%                               models with unstable dynamics).
%                               See HSVD and STABSEP for details.
%
%   See also LTI/HSVPLOT, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $   $Date: 2006/12/27 20:33:31 $
p = plotopts.HSVPlotOptions(varargin{:});

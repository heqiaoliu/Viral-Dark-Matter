%% Compensator Design for Plant Models with Time Delays
% This demo highlights a variety of analysis and design tools
% available for plant models with time delays in the SISO Design Tool.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $  $Date: 2009/08/29 08:21:48 $

%% Analysis and Design of Feedback Systems with Time Delays
% Consider the standard feedback configuration where the plant model
%
% $$ G(s) = e^{-0.5s}\frac{1}{s+1} $$ 
%
% has a time delay.
%
% <<../Figures/TimeDelayPlantDemo_Fig01.png>>

%%
% When working with time delay systems it is advantageous to work with
% analysis and design tools that directly support time delays so that
% performance and stability can be evaluated exactly. However, many control
% design techniques and algorithms cannot directly handle time delays. A
% common workaround consists of replacing delays by their Pade
% approximations (all-pass filters). Because this approximation is only
% valid at low frequencies, it is important to choose the right
% approximation order and check the approximation validity.

%%
% The SISO Design Tool provides a variety of design and analysis tools.
% Some of these tools support time delays exactly while others support
% time delays indirectly through approximations.  The SISO Design Tool
% allows you to utilize all these tools simultaneously and lets you
% visualize the compromises made when using approximations. A brief
% overview of working with time delays in the SISO Design tool will be
% given.



%% Working with Time Delay Systems in the SISO Design Tool
% The first step to begin working with the SISO Design Tool is to define
% the plant model and start the tool
%
% |>> G = tf(1,[1,1],'InputDelay',0.5);|
%
% |>> sisotool({'bode'},G)|

%% Tools that Support Time Delay 
% Examples of the tools which support time delays directly include:
%
% * Bode and Nichols Editors
% * Time Response Plots
% * Frequency Response Plots
%
% Shown below is the Bode Editor. In particular, by examining phase of the
% response we can see the roll off effect resulting from the exact
% representation of the delay.
%
% <<../Figures/TimeDelayPlantDemo_Fig02.png>>

%%
% Next we will examine the closed-loop step response and the open-loop
% Nyquist plot using the analysis views shown below. These plots are
% configured using the "Analysis Plots" tab.  First, lets evaluate the step
% response. Notice the initial portion of step response shows the exact
% representation of 0.5 second delay. Now lets focus on the Nyquist plot
% around the origin. Notice the response wrapping around the origin in a
% spiral fashion. This is the result of the exact representation of the
% time delay.
%
% <<../Figures/TimeDelayPlantDemo_Fig03.png>>

%% Tools that Require Time Delays to be Approximated
% Examples of the tools which approximate time delays include:
%
% * Root Locus Editor
% * Pole/Zero Plots
% * Many of the Automated Tuning Methods
%
% The drawback when using approximations is that the results are not exact
% and depend on the validity of the approximation. Each tool in the SISO
% Design Tool provides a warning pane to clearly inform you when a tool is
% using an approximation. We will now examine some of these tools and
% demonstrate how the approximation settings can be changed.

%%
% First lets examine the Root Locus editor. To bring up the Root Locus
% editor use the Graphical Tuning tab. Shown at the top of the Root Locus
% editor is the notification that tool is utilizing an approximation. This
% notification can be minimized by clicking on the collapse icon to the
% left.
%
% <<../Figures/TimeDelayPlantDemo_Fig04.png>>


%%
% To change the approximation settings we can click on the hyperlink in the
% notification which will launch the SISO Design Tool Preferences dialog.
% Here we can set the Pade order of the approximation explicitly or allow
% the order to be computed by specify a frequency for which we want the
% approximation to be accurate.
%
% <<../Figures/TimeDelayPlantDemo_Fig05.png>>
%

%%
% By changing the Pade order from 2 to 4 and clicking apply we see that the
% number of plant poles and zeros in the Root Locus editor increased due to
% the higher order approximation.
%
% <<../Figures/TimeDelayPlantDemo_Fig06.png>>

%% Summary
% The SISO Design Tool provides you a set of design and analysis tools for
% time delay systems. The tools which support time delays allow you to
% exactly analyze the performance and stability of the system.  Tools which
% do not support time delays utilize a Pade approximation of the time
% delay. The accuracy of the Pade approximation can be set using the
% preferences of the SISO Design Tool. Overall the SISO Design Tool gives
% deep insight into time delay control systems and the impact of
% approximations on evaluating performance and stability.


displayEndOfDemoMessage(mfilename)
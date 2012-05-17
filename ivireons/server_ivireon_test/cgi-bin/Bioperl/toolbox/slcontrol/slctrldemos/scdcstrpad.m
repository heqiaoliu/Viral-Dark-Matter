%% Plotting Linear System Characteristics of a Chemical Reactor
%
% The Simulink(R) Control Design(TM) software provides blocks that you 
% can add to Simulink(R) models to compute and plot linear systems  
% during simulation. In this demo, a linear system of a continuous-stirred
% chemical reactor is computed and plotted on a Bode plot as the reactor
% transitions through different operating points.  
 
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/05/10 17:56:26 $

%% Chemical Reactor Model
%
% Open the Simulink model of the chemical reactor:
open_system('scdcstr')
%%
% The reactor has three inputs and two outputs:
%
% * The |FeedCon0|, |FeedTemp0| and |Coolant Temp| blocks model the 
% inputs - feed concentration, feed temperature, and coolant temperature, respectively.
%
% * The |T| and |CA| ports of the |CSTR| block model the outputs - reactor temperature
% and residual concentration, respectively.
%
% This demo focuses on the response from coolant
% temperature, |Coolant Temp|, to residual concentration, |CA|, when the feed 
% concentration and feed temperature are constant.
%
% For more information on modeling reactors, see Seborg, D.E. et al., "Process Dynamics and Control",
% 2nd Ed., Wiley, pp.34-36.

%% Plotting the Reactor Linear Response
%
% The reactor model contains a |Bode Plot| block from the Simulink Control 
% Design Linear Analysis Plots library. The block is configured with:
%
% * A linearization input at the coolant temperature |Coolant Temp|.
%
% * A linearization output at the residual concentration |CA|.
%
% The block is also configured to perform linearizations on the rising edges of 
% an external trigger signal. The trigger signal is computed in the
% |Linearization trigger signal| block which produces a rising edge when 
% the residual concentration is:
% 
% * At a steady state value of 2
%
% * In a narrow range around 5
%
% * At a steady state value of 9
%
% Double-click the |Bode Plot| block to view the block configuration.
%
% <<../html_extra/scdcstr/LinearizationTab.png>>

%%
% Clicking  *Show Plot* in the Block Parameters dialog box opens a Bode Plot 
% window which shows the response of the computed linear system from |Coolant Temp|
% to |CA|. To compute the linear system and view its response, simulate the model 
% using one of the following:
%
% * Click the |Start simulation| button in the Bode Plot window.
%
% * Select *Simulation > Start* in the Simulink model window.
%
% * Type the following command: 
%
sim('scdcstr')

%%
% <<../html_extra/scdcstr/BodePlot.png>>
%
% The Bode plot shows the linearized reactor at three operating
% points corresponding to the trigger signals defined in the |Linearization
% trigger signal| block:
%
% * At 5 sec,  the linearization is for a low residual concentration.
%
% * At 38 sec, the linearization is for a high residual concentration.
%
% * At 27 sec, the linearization is as the reactor transitions from a low 
% to high residual concentration. 
%
% The linearizations at low and high residual concentrations are similar but
% the linearization during the transition has a significantly different DC gain 
% and phase characteristics. At low frequencies, the phase differs by
% 180 degrees, indicating the presence of either an unstable pole or zero.

%% Logging the Reactor Linear Response
%
% The *Logging* tab in the |Bode Plot| block specifies that the computed linear
% systems be saved as a workspace variable. 
%
% <<../html_extra/scdcstr/LoggingTab.png>>
%
% The linear systems are logged in a structure with 
% |time| and |values| fields.

LinearReactor

%%
% The |values| field stores the linear systems as an array of LTI state-space
% systems (see <matlab:helpview([docroot,'/toolbox/control/control.map'],'concept_of_an_lti_array') Arrays of LTI Models>)
% in Control System Toolbox documentation for more information). 
%
% You can retrieve the individual systems by indexing into the |values| field.
P1 = LinearReactor.values(:,:,1);
P2 = LinearReactor.values(:,:,2);
P3 = LinearReactor.values(:,:,3);

%%
% The Bode plot of the linear system at time 27 sec, when the reactor 
% transitions from low to high residual concentration, indicates that the system
% could be unstable. Displaying the linear systems in pole-zero format confirms this:
zpk(P1)
zpk(P2)
zpk(P3)

%%
% Close the Simulink model:
bdclose('scdcstr')
clear('LinearReactor','P1','P2','P3')
displayEndOfDemoMessage(mfilename)

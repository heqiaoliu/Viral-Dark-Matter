%% Compensator Design for a Set of Plant Models
% The SISO Design Tool provide a variety of design and analysis tools. This 
% demo shows how to analyze a controller design for multiple plant models.
%

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1.2.1 $  $Date: 2010/06/24 19:32:25 $

%% Acquiring a Set of Plant Models
% Consider the typical feedback problem, shown in the following figure,
% where the controller C is designed to satisfy some performance objective.
%
% <<../Figures/MultiModelPlantDemoFigures_01.png>>
%
% Typically, the dynamics of the system, G, are not exactly known and can 
% vary based on operating conditions.  For example:
%
% *  The variations in system dynamics may be a result of manufacturing
% tolerances that are typically defined as a range about the nominal value
% (e.g. the value of resistance for a resistor 5 ohms  +/-  1%) .
%
% *  The system dynamics vary with operating condition (e.g. aircraft
% dynamics change based on altitude and speed).
% 
% When designing controllers for these types of systems, the performance 
% objectives for all variations of the system must be satisfied.
%
% You can model such systems as a set of LTI models and create an LTI array to 
% store the collection of these models. Then, use the SISO Design to design a 
% controller for a nominal plant in the array and analyze the
% controller design for the set of plants.
%
% The following list summarizes how to obtain an array of LTI models:
%
% Control System Toolbox(TM)
%
% * Functions: <matlab:doc('stack') stack>, <matlab:doc('tf') tf>, <matlab:doc('zpk') zpk>, <matlab:doc('ss') ss>, <matlab:doc('frd') frd>
%
% Simulink(R) Control Design(TM)
%
% * Functions: <matlab:doc('frestimate') frestimate>, <matlab:doc('linearize') linearize>
% * Demo: <../../../slcontrol/slctrldemos/html/scddcmotorpad.html "Reference Tracking of a DC Motor with Parameter Variations">.
%
% Robust Control Toolbox(TM)
%
% * Functions: <matlab:doc('uss') uss>, <matlab:doc('usample') usample>, <matlab:doc('usubs') usubs>.
%
% System Identification Toolbox(TM)
%
% * Functions: <matlab:doc('pem') pem>, <matlab:doc('oe') oe>, <matlab:doc('arx') arx>.
%

%% Working with Multimodel Systems in the SISO Design Tool
% In this example, the plant model is a second order system defined as:
%
% $$ G(s) = \frac{\omega_n^2}{s^2 +2\zeta\omega_n s+\omega_n^2} $$
%
% with 
%
% $$ \omega_n = (1,1.5,2) $$ and $$ \zeta = (.2,.5,.8) $$.
%

%% Constructing the LTI Array
% The first step is to construct the LTI array for the combinations of
% $\zeta$ and $\omega_n$.

wn = [1,1.5,2];
zeta = [.2,.5,.8];
ct = 1;
for ct1 = 1:length(wn)
    for ct2 = 1:length(zeta)
        zetai = zeta(ct2);
        wni = wn(ct1);
        G(1,1,ct) = tf(wni^2,[1,2*zetai*wni,wni^2]); 
        ct = ct+1;
    end
end

size(G)

% Note that the array must be a row or column array.
%% Opening the SISO Design Tool
% Next, start the SISO Design Tool.
%
% |>> sisotool(G)|
%
% The SISO Design Tool opens with a Bode and Root Locus open-loop editors.
%
% <<../Figures/MultiModelPlantDemoFigures_02.png>>
%
% By default, the nominal model used for design is the first element in the
% LTI array.
%
% * The root locus editor displays the root locus for the nominal model and
% the closed loop pole locations associated with the set of plants. 
%
% * The Bode editor displays both the nominal model response and responses
% of the set of plants. 
%
% In these editors, you can interactively tune the gain,
% poles and zeros of the compensator while simultaneously visualizing the
% effect on the set of plants. 

%% Changing the Nominal Model
% To change the nominal model:
%
% 1. Go to the *Architecture* tab of the *SISO
% Design Task*.
%
% 2. Click *Multimodel Configuration*.  
%
% The *Multimodel Configuration Dialog* window allows you to change the nominal model.
%
% <<../Figures/MultiModelPlantDemoFigures_03.png>>
%
% For example, selecting 5 for the nominal model results in the following
% changes to the Bode and Root Locus editors.
%
% <<../Figures/MultiModelPlantDemoFigures_04.png>>

%% Options for Plotting Responses 
% The options for plotting responses of the set of plants are accessed by
% right-clicking the plots. Use *Multimodel Display* to:
% 
% * Turn off the responses.
% * Show them as individual responses or as an envelope encapsulating the
% individual responses as shown below.
%
% <<../Figures/MultiModelPlantDemoFigures_05.png>>

%% Summary
% The SISO Design Tool provides you design and analysis tools for
% multimodel systems. The tools allow you to analyze the performance and
% stability of a set of systems simultaneously. 


displayEndOfDemoMessage(mfilename)
%% Connecting Models
% This demo shows how to model interconnections of LTI systems, 
% from simple series and parallel connections to complex
% block diagrams.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/11/09 19:47:43 $

%% Overview
% Control System Toolbox(TM) provides a number of functions to help you
% build networks of LTI models.  These include functions to perform
%
% * Series and parallel connections (|series| and |parallel|)
% * Feedback connections (|feedback| and |lft|)
% * Input and output concatenations (|[ , ]|, |[ ; ]|, and |append|)
% * General block-diagram building (|connect|).
%
% These functions can handle any combination of model representations.
% For illustration purposes, create the following two SISO transfer 
% function models:
H1 = tf(2,[1 3 0])

%%
H2 = zpk([],-5,5)

%% Series Connection
% <<../Figures/GSConnectingModels_Fig02.png>>

%% 
% Use the |*| operator or the |series| function to connect LTI models in
% series, for example:
H = H2 * H1

%%
% or equivalently
H = series(H1,H2);

%% Parallel Connection
% <<../Figures/GSConnectingModels_Fig03.png>> 

%%
% Use the |+| operator or the |parallel| function to connect LTI models in
% parallel, for example:
H = H1 + H2

%%
% or equivalently
H = parallel(H1,H2);


%% Feedback Connections
% The standard feedback configuration is shown below:
%
% <<../Figures/GSConnectingModels_Fig04.png>>

%%
% To build a model of the closed-loop transfer from |u| to |y|, type
H = feedback(H1,H2)

%%
% Note that |feedback| assumes negative feedback by default. 
% To apply positive feedback, use the following syntax:
H = feedback(H1,H2,+1);

%% 
% You can also use the |lft| function to build the more general 
% feedback interconnection sketched below.
%
% <<../Figures/GSConnectingModels_Fig08.png>>




%% Concatenating Inputs and Outputs
% You can concatenate the inputs of the two models |H1| and |H2| by typing
H = [ H1 , H2 ]

%%
% The resulting model has two inputs and corresponds to the
% interconnection:
%
% <<../Figures/GSConnectingModels_Fig05.png>>

%% 
% Similarly, you can concatenate the outputs of |H1| and |H2|  by typing
H = [ H1 ; H2 ]

%%
% The resulting model |H| has two outputs and one input and 
% corresponds to the following block diagram:
%
% <<../Figures/GSConnectingModels_Fig06.png>>
    
%%
% Finally, you can append the inputs and outputs of two models using:
H = append(H1,H2)

%%
% The resulting model |H| has two inputs and two outputs and 
% corresponds to the block diagram:
%
% <<../Figures/GSConnectingModels_Fig07.png>>
 
%%
% You can use concatenation to build MIMO models from elementary SISO
% models, for example:
H = [H1 , -tf(10,[1 10]) ; 0 , H2 ]

%%
sigma(H), grid

%% Building Models from Block Diagrams
% You can use combinations of the functions and operations introduced so far to construct
% models of simple block diagrams. For example, consider
% the following block diagram:
%
% <<../Figures/GSConnectingModels_Fig09.png>>
%
% with the following data for the blocks |F|, |C|, |G|, |S|:
s = tf('s');
F = 1/(s+1);
G = 100/(s^2+5*s+100);
C = 20*(s^2+s+60)/s/(s^2+40*s+400);
S = 10/(s+10);

%% 
% You can compute the closed-loop transfer |T| from |r| to |y| as
T = F * feedback(G*C,S);
step(T), grid

%%
% For more complicated block diagrams, the |connect| function provides a
% systematic and simple way to wire  blocks together. To use |connect|,
% follow these steps:

%%
% <html>
% <ol>
% <li> Define all blocks in the diagram, including summation blocks </li>
% <li> Name all signals in the diagram </li>
% <li> Use signals names to specify the InputName and OutputName properties of
% each block. </li>
% </ol> 
% </html>

%%
%
% <<../Figures/GSConnectingModels_Fig10.png>>
%
% For the block diagram above, these steps amount to:
Sum1 = sumblk('e','r','y','+-');
Sum2 = sumblk('u','uC','uF','++');

% Define the block I/Os
F.inputname = 'r';   F.OutputName = 'uF';
C.inputname = 'e';   C.OutputName = 'uC';
G.inputname = 'u';   G.OutputName = 'ym';
S.inputname = 'ym';  S.OutputName = 'y';

% Compute transfer r -> ym
T = connect(F,C,G,S,Sum1,Sum2,'r','ym');
step(T), grid

%% Precedence Rules
% When connecting models of different types, the resulting model type is
% determined by the precedence rule 

%%
%    FRD > SS > ZPK > TF

%%
% This rule states that FRD has highest precedence, followed by SS and ZPK, and TF has
% the lowest precedence. For example, in the series connection:
H1 = ss(-1,2,3,0);
H2 = tf(1,[1 0]);
H = H2 * H1;

%%
% |H2| is automatically converted to the state-space representation and the
% result |H| is a state-space model:
class(H)

%%
% Because the SS and FRD representations are best suited for system
% interconnections, it is recommended that you cast at least one of the models to
% SS or FRD to ensure that all computations are performed using one of
% these two representations. For example, the computation of |T| above is 
% best performed by
T = connect(ss(F),C,G,S,Sum1,Sum2,'r','ym');


displayEndOfDemoMessage(mfilename)
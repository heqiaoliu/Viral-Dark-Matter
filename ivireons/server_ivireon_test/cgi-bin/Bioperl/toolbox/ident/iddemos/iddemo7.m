%%  Building Structured and User-Defined Models Using System Identification Toolbox(TM)
% In this demo we shall demonstrate how to use utilities in System Identification Toolbox(TM) 
% to estimate parameters in user-defined model structures. Such structures 
% are specified by IDPROC (transfer function), IDGREY (state-space) or IDNLGREY 
% models. Here, we shall consider linear models (IDPROC, IDGREY) only. We shall 
% investigate how to assign structure, fix parameters and create dependencies among them. 

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.9.4.8 $ $Date: 2010/03/22 03:48:23 $

%% Experiment Data
% We shall investigate data produced by a (simulated) dc-motor.
% We first load the data: 
load dcmdata
who
%%
% The matrix |y| contains the two outputs: |y1| is the angular position of
% the motor shaft and |y2| is the angular velocity. There are 400 data
% samples and the sampling interval is 0.1 seconds. The input is
% contained in the vector |u|. It is the input voltage to the motor.
z = iddata(y,u,0.1); % The IDDATA object
z.InputName = 'Voltage';
z.OutputName = {'Angle';'AngVel'};
plot(z(:,1,:))
%%
% *Figure: Measurement Data: Voltage to Angle*
plot(z(:,2,:))
%%
% *Figure: Measurement Data: Voltage to Angle*


%% Model Structure Selection
% We shall build a model of the dc-motor. The dynamics of the motor is
% well known. If we choose x1 as the angular position and x2 as the
% angular velocity it is easy to set up a state-space model of the
% following character neglecting disturbances:
% (see Example 4.1 in Ljung(1999):
%
%           | 0     1  |      | 0   |
%  d/dt x = |          | x  + |     | u
%           | 0   -th1 |      | th2 |
%
%
%          | 1  0 |
%     y =  |      | x
%          | 0  1 |
%

%%
% The parameter |th1| is here the inverse time-constant of the motor and
% |th2| is such that |th2/th1| is the static gain from input to the angular
% velocity. (See Ljung(1987) for how |th1| and |th2| relate to the physical
% parameters of the motor). We shall estimate these two parameters from the
% observed data. The model structure (parameterized state space) described
% above can be represented in MATLAB(R) using IDSS and IDGREY objects. These
% objects let you perform estimation of parameters using experimental data.


%% Specification of Free (Independent) Parameters Using IDSS Models
% IDSS models represent state-space models. The structure in terms of the
% general description:
%
%       d/dt x = A x + B u + K e
%
%       y   = C x + D u + e
%

%% 
% The parameters of the model are the system matrices - |A|, |B|, |C|, |D|
% and |K| and the initial state values X0. With IDSS objects, you have the
% option of specifying which elements of the system matrices are fixed to
% known values, and which are to be estimated. This specification is
% performed using "structure matrices" |As|, |Bs|, |Cs|, |Ds|, |Ks| and
% |X0s|. Any parameter to be estimated is entered as NaN (Not a Number). 
%
% Thus we have the following structure matrices:
As = [0 1; 0 NaN];
Bs = [0; NaN];
Cs = [1 0; 0 1];
Ds = [0; 0];
Ks = [0 0;0 0];
X0s = [0;0];   % X0 is the initial value of the state vector; it could also be
               % entered as parameters to be identified.

%%
% We shall produce an initial guess for the parameters marked with
% NaN above. Let us guess  that the time constant is one second 
% and that the static gain is 0.28. This gives:

A = [0 1; 0 -1]; %initial guess for A(2,2) is -1
B = [0; 0.28]; %initial guess for B(2) is 0.28
C = eye(2); % C is completely fixed by Cs. Hence C = Cs.
D = zeros(2,1); % D is completely fixed by Ds. Hence D = Ds.

%%
% The nominal model can now defined using |idss| as follows:
ms = idss(A,B,C,D);
%%
% To define the "structure", i.e., which parameters to estimate:
setstruc(ms,As,Bs,Cs,Ds,Ks,X0s); 
set(ms,'Ts',0)  % This defines the model to be continuous (Sampling interval 0) 
ms % Initial model

%% Estimation of Free Parameters of the IDSS Model
% The prediction error (maximum likelihood) estimate of the parameters
% is now computed by:
dcmodel = pem(z,ms,'display','on');
dcmodel

%%
% The estimated values of the parameters are quite close to those used
% when the data were simulated (-4 and 1).
% To evaluate the model's quality we can simulate the model with the
% actual input by and compare it with the actual output.
compare(z,dcmodel);

%% 
% We can now, for example plot zeros and poles and their uncertainty
% regions. We will draw the regions corresponding to 10 standard
% deviations, since the model is quite accurate. Note that the pole at the
% origin is absolutely certain, since it is part of the model structure;
% the integrator from angular velocity to position. 
pzmap(dcmodel,10)

%%
% Now, we may make various modifications. The 1,2-element of the A-matrix
% (fixed to 1) tells us that |x2| is the derivative of |x1|. Suppose that
% the sensors are not calibrated, so that there may be an unknown 
% proportionality constant. To include the estimation of such a constant
% we just "let loose" |A(1,2)| and re-estimate:
dcmodel2 = dcmodel;
dcmodel2.As(1,2) = NaN;
dcmodel2 = pem(z,dcmodel2,'display','on'); 

%%
% The resulting model is
dcmodel2

%%
% We find that the estimated |A(1,2)| is close to 1.
% To compare the two model we use
compare(z,dcmodel,dcmodel2)

%% Specification of Models with Coupled Parameters Using IDGREY Objects
% Suppose that we accurately know the static gain of the dc-motor (from
% input voltage to angular velocity, e.g. from a previous step-response
% experiment. If the static gain is |G|, and the time constant of the
% motor is t, then the state-space model becomes
%
%            |0     1|    |  0  |
%  d/dt x =  |       |x + |     | u
%            |0  -1/t|    | G/t |
%
%            |1   0|
%     y   =  |     | x
%            |0   1|
%

%%
% With |G| known, there is a dependence between the entries in the
% different matrices. In order to describe that, the earlier used way
% with "NaN" will not be sufficient. We thus have to write a MATLAB file
% which produces the |A|, |B|, |C|, |D|, |K| and |X0| matrices as outputs,
% for each given parameter vector as input. It also takes auxiliary
% arguments as inputs, so that the user can change certain things in the
% model structure, without having to edit the file. In this case we let
% the known static gain |G| be entered as such an argument. The file that
% has been written has the name 'motor.m'.
type motor

%%
% We now create a IDGREY model object corresponding to this model
% structure: The assumed time constant will be
par_guess = 1;

%%
% We also give the value 0.25 to the auxiliary variable |G| (gain)
% and sampling interval.
aux = 0.25;
dcmm = idgrey('motor',par_guess,'cd',aux,0);

%%
% The time constant is now estimated by
dcmm = pem(z,dcmm,'display','on');
% We have thus now estimated the time constant of the motor directly.
% Its value is in good agreement with the previous estimate.
dcmm

%%
% With this model we can now proceed to test various aspects as before.
% The syntax of all the commands is identical to the previous case.
% For example, we can compare the idgrey model with the other
% state-space model:
compare(z,dcmm,dcmodel)
%
% They are clearly very close.

%% Estimating Multivariate ARX Models 
% The state-space part of the toolbox also handles multivariate (several
% outputs) ARX models. By a multivariate ARX-model we mean the
% following: 

%%
% |A(q) y(t) = B(q) u(t) + e(t)|
%
% Here A(q) is a ny | ny matrix whose entries are polynomials in the
% delay operator 1/q. The k-l element is denoted by:
%
% $$a_{kl}(q)$$
%
% where:
%
% $$a_{kl}(q) = 1 + a_1 q^{-1}    + .... + a_{nakl} q^{-nakl} q$$
%
% It is thus a polynomial in |1/q| of degree |nakl|.
% 
%%
% Similarly B(q) is a ny | nu matrix, whose kj-element is:
%
% $$b_{kj}(q) = b_0 q^{-nkk}+b_1 q^{-nkkj-1}+ ... +b_{nbkj} q^{-nkkj-nbkj}$$
%

%%
% There is thus a delay of |nkkj| from input number |j| to output number
% |k|. The most common way to create those would be to use the ARX-command.
% The orders are specified as:
% |nn = [na nb nk]|
% with |na| being a |ny-by-ny| matrix whose |kj|-entry is |nakj|; |nb| and
% |nk| are defined similarly.

%%
% Let's test some ARX-models on the dc-data. First we could simply build
% a general second order model:
dcarx1 = arx(z,'na',[2,2;2,2],'nb',[2;2],'nk',[1;1]);
dcarx1

%%
% The result, |dcarx1|, is stored as an IDARX model, and all previous
% commands apply. We could for example explicitly determine the
% ARX-polynomials by:
dcarx1.A
dcarx1.B 

%%
% We could also test a structure, where we know that |y1| is obtained by
% filtering |y2| through a first order filter. (The angle is the integral
% of the angular velocity). We could then also postulate a first order
% dynamics from input to output number 2:
na = [1 1; 0 1];
nb = [0 ; 1];
nk = [1 ; 1];
dcarx2 = arx(z,[na nb nk]);
dcarx2

%%
% To compare the different models obtained we use
compare(z,dcmodel,dcmm,dcarx2)

%%
% Finally, we could compare the bodeplots obtained from the input to
% output one for the different models by using |bode|:
%  First output:
bode(dcmodel(1,1),'r',dcmm(1,1),'b',dcarx2(1,1),'g')
%%
%  Second output:
bode(dcmodel(2,1),'r',dcmm(2,1),'b',dcarx2(2,1),'g')

%%
% The two first models are more or less in exact agreement. The
% ARX-models are not so good, due to the bias caused by the non-white
% equation error noise. (We had white measurement noise in the
% simulations).

%% Conclusions
% Estimation of models with pre-selected structures can be performed using
% System Identification toolbox. In state-space form, parameters may be
% fixed to their known values using structure matrices of IDSS objects. If
% relationship between parameters or other constraints need to be
% specified, IDGREY objects may be used. IDGREY models evaluate a
% user-specified MATLAB file for estimating state-space system parameters.
% Multi-variate ARX models offer another option for quickly estimating
% multi-output models with user-specified structure. 
%%
% For low order continuous-time transfer functions, IDPROC objects may be
% used. These objects let you create simple "process" models with the
% option of fixing some parameters to their known values. Such models are
% popular in process industry. To learn more about these models in System
% Identification Toolbox, see the demo: "Building and Estimating Process
% Models Using System Identification Toolbox".
% 

%% Additional Information
% For more information on identification of dynamic systems with System
% Identification Toolbox visit the
% <http://www.mathworks.com/products/sysid/ System Identification Toolbox> product
% information page.

displayEndOfDemoMessage(mfilename)

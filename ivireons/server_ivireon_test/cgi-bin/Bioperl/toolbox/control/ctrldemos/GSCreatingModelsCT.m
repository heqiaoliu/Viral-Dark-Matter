%% Creating Continuous-Time Models
% This demo shows how to create continuous-time linear models using the
% |tf|, |zpk|, |ss|, and |frd| commands.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/11/09 19:47:45 $

 
%% LTI Model Types
% Control System Toolbox(TM) provides functions for creating four basic
% representations of linear time-invariant (LTI) models:
%
% * Transfer function (TF) models 
% * Zero-pole-gain (ZPK) models 
% * State-space (SS) models 
% * Frequency response data (FRD) models 
%
% These functions take model data as input and create objects that embody
% this data in a single MATLAB(R) variable.


%% Creating Transfer Function Models
% Transfer functions (TF) are frequency-domain representations of LTI systems.
% A SISO transfer function is a ratio of polynomials:
% 
% $$ H(s) = \frac{A(s)}{B(s)} = \frac{a_{1} s^{n} + a_{2} s^{n-1} + \ldots + a_{n+1}}{b_{1}
% s^{m} + b_{2} s^{m-1} + \ldots + b_{m+1}} $$
%
% Transfer functions are specified by their numerator and denominator
% polynomials |A(s)| and |B(s)|. In MATLAB, a polynomial is represented by
% the vector of its coefficients, for example, the polynomial
%        
% $$  s^{2} + 2 s + 10 $$
%
% is specified as |[1 2 10]|.
%
% To create a TF object representing the transfer function:
%
% $$ H(s) = \frac{s}{s^2+2s+10}  $$
%
% specify the numerator and denominator polynomials and use |tf| to
% construct the TF object:
num = [ 1  0 ];       % Numerator: s
den = [ 1  2  10 ];   % Denominator: s^2 + 2 s + 10
H = tf(num,den)

%%
% Alternatively, you can specify this model as a rational expression of the 
% Laplace variable |s|:
s = tf('s');        % Create Laplace variable
H = s / (s^2 + 2*s + 10)

%% Creating Zero-Pole-Gain Models
% Zero-pole-gain (ZPK) models are the factored form of transfer functions:
%
% $$ H(s) = k \frac{( s - z_{1} ) \ldots ( s - z_{n} )}{( s - p_{1} ) \ldots
% ( s - p_{m} )} $$
%
% Such models expose the roots |z| of the numerator (the zeros) and the
% roots |p| of the denominator (the poles). The scalar coefficient |k| is
% called the gain.
% 
% To create the ZPK model:
%
% $$ H(s) = \frac{-2 s}{( s - 2 ) ( s^2 - 2 s + 2 )} $$
%
% specify the vectors of poles and zeros and the gain |k|:
z = 0;                   % Zeros
p = [ 2  1+i  1-i ];     % Poles
k = -2;                  % Gain
H = zpk(z,p,k)

%%
% As for TF models, you can also specify this model as a rational expression of |s|:
s = zpk('s');
H = -2*s / (s - 2) / (s^2 - 2*s + 2)
 

%% Creating State-Space Models
% State-space (SS) models are time-domain representations of LTI systems:
%
% $$ \frac{dx}{dt} = A x(t) + B u(t) $$
%
% $$ y(t) = Cx(t) + Du(t) $$
%
% where |x(t)| is the state vector, |u(t)| is input vector, and 
% |y(t)| is the output trajectory. 
%
% State-space models are derived from the differential equations 
% describing the system dynamics. For example, consider the 
% second-order ODE for a simple electric motor:
%
% $$ \frac{d^2\theta}{dt^2} + 2\frac{d\theta}{dt} + 5\theta = 3I $$
%
% where |I| is the driving current (input) and |theta| is the angular
% displacement of the rotor (output). This ODE can be rewritten in
% state-space form as:
%
% $$ \frac{dx}{dt} = Ax + BI~~~~~~~A = \left[\matrix{0 & 1 \cr
% -5 & -2 }\right] ~~~~~~~  B=\left[\matrix{0 \cr 3 }\right]~~~~~~~
% x=\left[\matrix{\theta \cr \frac{d\theta}{dt} }\right] $$
%
% $$ \theta = Cx + DI~~~~~~~C=[1~~0]~~~~~~~D = [0] $$
%
% To create this model, specify the state-space matrices |A, B, C, D| and
% use |ss| to construct the SS object: 
A = [ 0  1 ; -5  -2 ];
B = [ 0 ; 3 ];
C = [ 1  0 ];
D = 0;
H = ss(A,B,C,D)

%% Creating Frequency Response Data Models
% Frequency response data (FRD) models let you store the measured
% or simulated complex frequency response of a system in an LTI object. You
% can then use this data as a surrogate model for frequency-domain analysis 
% and design purposes.
% 
% For example, suppose you get the following data out of a frequency
% analyzer:
%
% * Frequency (Hz): 10, 30, 50, 100, 500
% * Response:  0.0021+0.0009i, 0.0027+0.0029i, 0.0044+0.0052i, 0.0200-0.0040i, 0.0001-0.0021i
%
% You can create an FRD object containing this data using:
freq = [10, 30, 50, 100, 500];
resp = [0.0021+0.0009i, 0.0027+0.0029i, 0.0044+0.0052i, 0.0200-0.0040i, 0.0001-0.0021i];
H = frd(resp,freq,'Units','Hz')

%%
% Note that frequency values are assumed to be in rad/s unless you specify the
% |Units| to be Hertz. 

%% Creating MIMO Models
% The |tf|, |zpk|, |ss|, and |frd| commands let you construct both SISO and
% MIMO models. For TF or ZPK models, it is often convenient to
% construct MIMO models by concatenating simpler SISO models. For example,
% you can create the 2x2 MIMO transfer function:
%
% $$ H(s) = \left[ \begin{array}{cc} {1\over s+1} & 0 \\ & \\ {s+1 \over s^2+s+3}
% & {-4s \over s+2} \end{array} \right] $$
%
% using:
s = tf('s');
H = [ 1/(s+1) , 0 ; (s+1)/(s^2+s+3) , -4*s/(s+2) ]

%% Analyzing LTI Models
% Control System Toolbox provides an extensive set of functions for
% analyzing LTI models. These functions range from simple queries about I/O size and order to
% sophisticated time and frequency response analysis. 
%
% For example, you can obtain size information for the MIMO transfer
% function |H| specified above by typing:
size(H)

%%
% You can compute the poles using:
pole(H)

%%
% You can ask whether this system is stable using:
isstable(H)

%% 
% Finally, you can plot the step response by typing:
step(H)

%%
% See the *Model Analysis* demos for more details.

displayEndOfDemoMessage(mfilename)
 
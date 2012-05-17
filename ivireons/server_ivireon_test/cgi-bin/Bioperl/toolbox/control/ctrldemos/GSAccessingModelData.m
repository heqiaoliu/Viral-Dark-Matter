%% Accessing and Modifying the Model Data
% This demo shows how to access or edit parameter values and metadata
% in LTI objects.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/02/08 22:29:44 $


%% Accessing Data
% The |tf|, |zpk|, |ss|, and |frd| commands create LTI objects 
% that store model data in a single MATLAB(R) variable. This data
% includes model-specific parameters (e.g., A,B,C,D matrices for
% state-space models) as well as generic metadata such as input and output 
% names. The data is arranged into a fixed set of data fields called
% *properties*.
%
% You can access model data in the following ways:
%
% * The |get| command
% * Structure-like dot notation
% * Data retrieval commands
%
% For illustration purposes, create the SISO transfer function (TF):
G = tf([1 2],[1 3 10],'inputdelay',3)

%%
% To see all properties of the TF object |G|, type
get(G)

%% 
% The first four properties |num|, |den|, |ioDelay|, and |Variable| are specific to
% the TF representation. The remaining properties are common to all LTI
% representations. You can use |help tf.num| to get more information on the "num" 
% property and similarly for the other properties.
%
% To retrieve the value of a particular property, use
G.InputDelay    % get input delay value

%%
% You can use abbreviations for property names as long as they are
% unambiguous, for example:
G.iod    % get transport delay value

%%
G.var    % get variable

%% Quick Data Retrieval
% You can also retrieve all model parameters at once using |tfdata|,
% |zpkdata|, |ssdata|, or |frdata|. For example:
[num,den,Ts] = tfdata(G)

%%
% Note that the numerator and denominator are returned as cell arrays. This
% is consistent with the MIMO case where |num| and |den| contain cell arrays
% of numerator and denominator polynomials (with one entry per I/O pair).
% For SISO transfer functions, you can return the numerator and
% denominator data as vectors by using a flag, for example:
[num,den] = tfdata(G,'v')

%% Editing Data
% You can modify the data stored in LTI objects by editing the
% corresponding property values with |set| or dot notation. 
% For example, for the transfer function |G| created above, 
G.Ts = 1;

%%
% changes the sampling time from 0 to 1, which redefines the model as discrete:
G,

%%
% The |set| command is equivalent to dot assignment, but also lets you set
% multiple properties at once:
set(G,'Ts',0.1,'Variable','q')
G,

%% Sensitivity Analysis Example
% Using model editing together with LTI array support, you can easily
% investigate sensitivity to parameter variations. For example, consider
% the second-order transfer function
% 
% $$ H(s) = { s+5 \over s^2 + 2 \zeta s + 5 } $$
%
% You can investigate the effect of the damping parameter |zeta| on the
% frequency response by creating three models with different |zeta| values
% and comparing their Bode responses:
s = tf('s');

% Create 3 transfer functions with num=s+1 and den=1
H = repsys(s+5,[1 1 3]);  

% Specify denominators using 3 different zeta values
zeta = [1 .5 .2];
for k=1:3
  H(:,:,k).den = [1 2*zeta(k) 5];  % zeta(k) -> k-th model
end

% Plot Bode response
bode(H), grid


displayEndOfDemoMessage(mfilename)
 
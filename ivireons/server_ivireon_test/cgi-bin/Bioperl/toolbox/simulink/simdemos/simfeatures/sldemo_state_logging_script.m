%% Logging States in Structure Format
% This demo illustrates the advantages of logging state trajectories of a Simulink(R)
% model in structure format over the traditional method of logging the states in
% array format, as a matrix with N columns, where N is the number of states.
% The ordering of the states along the columns in the logged matrix depends on
% the block sorted order, which is determined by Simulink Engine during
% compilation. Various factors may affect the sorted order of the blocks, which
% in turns alters the ordering of the states.
%
% This demo illustrates how logging the states in Structure format, which stores
% the block names together with the state trajectories, can help avoid the state
% ordering problem.  

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/12/01 07:49:32 $

%% Problem with Logging in Array Format 
% By default Simulink logs the state trajectories in array format, as the data
% in this form as an M-by-N matrix is easy to manipulate in MATLAB(R). The ordering of
% the state variables along the columns of the logged matrix depend on the block
% sorted order. MATLAB code that expects a fixed mapping between the columns of
% the matrix and the states, can break when the block sorted order changes due
% to changes in the model.
% 
% Consider for example, the following two block diagrams:

mdl1 = 'sldemo_state_logging1';
mdl2 = 'sldemo_state_logging2';
open_system(mdl1);
open_system(mdl2);

%%
% The two diagrams have the same blocks, the only difference is the ordering of
% output ports. Simulate the models and log the states in array format: 

opts1 = simset(simget(mdl1),'SaveFormat','Array');
[t1,x1] = sim(mdl1, [], opts1);

opts2 = simset(simget(mdl2),'SaveFormat','Array');
[t2,x2] = sim(mdl2, [], opts2);

%%
% Note that the relative ordering of the integrator blocks is different
% in the two block diagrams. This causes the logged states |x1| and |x2| to
% differ, because the mapping between the columns and the states is
% different!

isequal(x1, x2)

%% Using Structure Format Logging
% Let us now simulate the models again, but this time log the states in
% structure format:

opts1 = simset(simget(mdl1),'SaveFormat','Structure');
[t1,x1s]=sim(mdl1,[],opts1); x1s

opts2 = simset(simget(mdl2),'SaveFormat','Structure');
[t2,x2s]=sim(mdl2,[],opts2); x2s

%%
% The state trajectories are logged into |xs.signals(k).values| along with the
% name of the block |xs.signals(k).blockName| corresponding to these states. We
% can extract the states into a matrix (like in array format) like this:

x1a = [x1s.signals.values];
x2a = [x2s.signals.values];

%%
% However we still have not address the state ordering problem (|x1a| and |x2a|
% are the same as |x1| and |x2| obtained via array format):

isequal(x1a, x2a)

%% Obtaining States Matrix with Fixed State Order
% To fix the state ordering problem, we use the block names stored along with
% the values to map the states to a fixed order such as alphabetical order of
% the block names: 

[unused, idx1] = sort({x1s.signals.blockName});
x1 = [x1s.signals(idx1).values];

[unused, idx2] = sort({x2s.signals.blockName});
x2 = [x2s.signals(idx2).values];

isequal(x1, x2)

%%
% By re-ordering the signals arrays in |x1| and |x2| to be in alphabetical order
% of the block names, and extracting the values fields, in that order, into the
% matrices |x1| and |x2|, we have a mechanism for logging the states into a
% matrix with a fixed mapping of the states to columns of the logged matrix.


displayEndOfDemoMessage(mfilename)


%% Code Reuse Using the For Each Subsystem
% 
%In this demo we illustrate the code reuse that happens when different For 
%Each Subsystems containing identically connected components are fed with signals of 
%different size.

% Copyright 2009 The MathWorks, Inc.


%% Code reuse for identical subsystems
% Previously, the fact that two subsystems are structurally identical was 
% not enough to guarantee that they would share the function generated for
% one of them. Since dimensions were hard coded in the function body, the
% input signals to these subsystems had to have identical sizes in order
% for the code to be reused. 
%
% In contrast, For Each Subsystems allow input signals to have different sizes
% and to provide code reuse. The equal size condition is relaxed to 
% only requiring an input signal size equal to a multiple of the partition width.
% Two For Each Subsystems are identical for the purpose of code reuse if they
% are structurally identical, and the partition dimensions and widths are 
% respectively the same.
% 
%% For Each Subsystems
% These subsystems process slices of the input. A slice is defined as a subarray
% of the input, for which all the dimension sizes are preserved but one -
% the dimension upon which Simulink(R) iterates. For example, a [6x4] signal can be sliced along the 
% first dimension into either 6 signals of [1x2], 3 signals of [2x2], 2 signals
% of [3x2], or simply 1 signal of the full size. The same applies to the second
% dimension. Each For Each Subsystem operates only in one dimension. 
% There is no need to specify the number of slices contained in a signal 
% entering a For Each Subsystem, as long as it is a multiple of the selected
% partition width.
%
%% Vector and matrix processing
% The examples in this demo consist of three structurally identical For Each
% Subsystems with different vector input signal sizes and two structurally 
% identical For Each Subsystems with different matrix input signal sizes.
% The three vector For Each Subsystems generate one reusable function
% and the other two For Each Subsystems generate a second reusable function.


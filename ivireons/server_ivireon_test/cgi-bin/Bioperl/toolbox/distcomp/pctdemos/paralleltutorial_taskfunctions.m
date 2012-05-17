%% Writing Task Functions
% In this demo, we look at two common cases when we might want to write a  
% wrapper function for the Parallel Computing Toolbox(TM).  Those wrapper 
% functions will be our task functions and will allow us to use the toolbox in 
% an efficient manner.  The particular cases are:
% 
% * We want one task to consist of calling a nonvectorized function
% multiple times.
% * We want to reduce the amount of data returned by a task.
%
% Prerequisites:
% 
% * <paralleltutorial_defaults.html
% Customizing the Settings for the Demos in the Parallel Computing Toolbox>
% * <paralleltutorial_dividing_tasks.html
% Dividing MATLAB(R) Computations into Tasks>
%
% For further reading, see: 
%
% * <paralleltutorial_network_traffic.html Minimizing Network Traffic>
% * <paralleltutorial_callbacks.html Using Callback Functions>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:09 $

%% Calling a Nonvectorized Function Multiple Times in a Task
% The <paralleltutorial_dividing_tasks.html
% Dividing MATLAB Computations into Tasks> 
% demo discusses how inefficient it would be to construct a large number of
% tasks where each task performs only a small amount of work.  Instead, each
% task should perform a reasonable amount of work, so that the overhead of a
% task does not dwarf its run time.  Consequently, we often find ourselves in
% the situation where each task should do the following:
%
% Given a vector |x|, return a vector |y| such that |y(i) = f(x(i))|.  If the
% function |f| is vectorized, the MATLAB statement |y = f(x)| does exactly
% that, so we let |f| be our task function.  However, if |f| is not
% vectorized, we have to write a task function that calls |f| inside a
% for-loop.  That is, we want the task function to look like the 
% following: 
%
%   function y = mytaskfnc(x)
%   len = numel(x);
%   y = zeros(1, len);
%   for i = 1:len
%    y(i) = f(x(i));
%   end

%%
% As an example, let's look at the problem of minimizing the Rosenbrock test
% function from multiple starting points.  Suppose that we want the starting
% point to be of the form |[-d, d]| and that we want to use the |fminsearch|
% method to perform the minimization.  We easily arrive at the following task
% function:
type pctdemo_task_tutorial_taskfunction;

%%
% We can create a job that is composed of several tasks, where each task can 
% handle as many different starting points as we need.

%% Reducing the Data Returned by a Task
% Our tasks might invoke some MATLAB functions that generate more data than we
% are interested in.  Since there is considerable overhead in transmitting the
% return data over the network, we would like to minimize such data transfers.
% Thus, the task function might look something like the following:
%
%   function d = mytaskfnc(x)
%   % Only return the last output argument from f.  Drop the rest.
%   [a, b, c, d] = f(x);
%
% There are of course numerous other possibilities: We might want to return only
% the sum of a vector instead of the entire vector, the last point of a time
% series instead of the entire time series, etc.


displayEndOfDemoMessage(mfilename)

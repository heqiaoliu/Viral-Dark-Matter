function xmin = pctdemo_task_tutorial_taskfunction(x)
%pctdemo_task_tutorial_taskfunction Minimize the Rosenbrock function.
%   xmin = pctdemo_task_tutorial_taskfunctions(x) returns the minimum of the 
%   Rosenbrock function that is found by starting at [-x(i), x(i)].
%   The output vector xmin is of the same length as the input vector x.
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:06:00 $
    
    xmin = zeros(numel(x), 2);
    for i = 1:numel(x)
        xmin(i, :) = fminsearch(@iRosenbrock, [-x(i), x(i)]);
    end
end % End of pctdemo_task_tutorial_taskfunction.

function y = iRosenbrock(x)
% The well-known optimization test function, the Rosenbrock function.
    y = 100*(x(2)-x(1)^2)^2+(1-x(1))^2;
end 

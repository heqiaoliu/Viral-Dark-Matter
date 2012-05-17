function pctdemo_taskfin_callback2(task, eventdata)
%PCTDEMO_TASKFIN_CALLBACK2 Update a graph using the task input and output data.
%   The function adds the current task results to the graph depicting all 
%   the results obtained so far.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:06:04 $
 
    % Find the plot that we want to modify, and add the task input and output 
    % data to the x- and y-axes of the plot, respectively.
    p = findobj('Tag', 'pctdemo_taskfin_callbacks2_plot');
    if ~ishandle(p)
        % We cannot plot onto a nonexisting graph.
        return;
    end
    inArgs = get(task, 'InputArguments');
    outArgs = get(task, 'OutputArguments');
    currX = inArgs{1};
    currY = outArgs{1};
    % Add the point (currX, currY) to the list of points currently on the graph.
    x = get(p, 'XData');
    y = get(p, 'YData');
    x = [x, currX];
    y = [y, currY];
    % We want the lines connecting the data points to approximate the graph of 
    % the function, so we sort the data points by their x-value.
    [x, ind] = sort(x);
    y = y(ind);
    % Update the graph.
    set(p, 'XData', x, 'YData', y)
end % End of pctdemo_taskfin_callback2.


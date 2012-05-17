function pctdemo_taskfin_callback2_setup()
%pctdemo_taskfin_callback2_setup Prepare a figure for drawing a graph.
%   The function initializes the output figure and tags it so that 
%   PCTDEMO_TASKFIN_CALLBACK2 can access it and modify its graph.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:06:05 $

    p = findobj('Tag', 'pctdemo_taskfin_callbacks2_plot');
    if isempty(p) || ~ishandle(p)
        fig = figure;
        figure(fig);
        p = plot(NaN, NaN, '.-');
        set(p, 'Tag', 'pctdemo_taskfin_callbacks2_plot');
        title('The square root function');
    end
    set(p, 'XData', [], 'YData', [])
end % End of pctdemo_taskfin_callback2_setup.

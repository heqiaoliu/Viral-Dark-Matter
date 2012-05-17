function printDepViewer(fig)    

% Copyright 2006 The MathWorks, Inc.
    
    if(~ishandle(fig))
        fig = figure;
        set(fig, 'Visible', 'off');
        printdlg('-crossplatform', fig);
        close(fig);
    else
        set(fig, 'Tag', 'DAStudio.DepViewer', ...
           'PaperPositionMode', 'auto', ...
           'Color', 'none'); 
        currAxes = get(fig,'CurrentAxes');
        origAxesPos = get(currAxes,'Position');

        printdlg('-crossplatform', fig, origAxesPos, origAxesPos);       
    end
    

end
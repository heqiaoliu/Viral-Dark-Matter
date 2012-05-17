function wb = createPreview(h,ts,wb)

% Copyright 2006 The MathWorks, Inc.

%% Create a preview of the plot for early viewing...
wb = waitbar(0,xlate('Initializing Time Series Plot'),'Name',...
    xlate('Time Series Tools'));

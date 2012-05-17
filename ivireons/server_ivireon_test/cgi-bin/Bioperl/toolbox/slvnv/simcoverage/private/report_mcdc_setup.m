function report_mcdc_setup(varargin)
% MCDC_SETUP - Generate a global data structure 
% to support reporting for mcdc coverage.

% Copyright 1990-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2005/12/19 07:55:45 $

    global gmcdc;
    
    gmcdc = varargin{1}.metrics.mcdc;
    
    for i=2:length(varargin)
        appendMetric = varargin{i}.metrics.mcdc;
        if isempty(appendMetric)
            appendMetric = zeros(length(gmcdc), 1);
        end; %if
        gmcdc = [gmcdc appendMetric];
    end
    



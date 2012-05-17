function [fig, count] = pctdemo_setup_bench(difficulty)
%PCTDEMO_SETUP_BENCH Perform the initialization for the Parallel Computing
%Toolbox Benchmarking demos.
%   [fig, count] = pctdemo_setup_bench(difficulty) returns the output figure 
%   for the Benckmarking demo as well as the number of times the benchmark  
%   should be repeated.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:38 $
    
    fig = pDemoFigure();
    clf(fig);
    set(fig, 'Name', 'Benchmark');
    set(fig, 'Visible', 'off');
    
    if (abs(difficulty - 1.0) > eps)
        warning('distcomp:demo:CanNotSetDifficulty', ...
                'Cannot set difficulty level to %3.2f', difficulty);
    end
    count = 4;
end %End of pctdemo_setup_bench

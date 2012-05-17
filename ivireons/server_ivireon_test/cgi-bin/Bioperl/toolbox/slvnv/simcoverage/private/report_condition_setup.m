function report_condition_setup(varargin)
% CONDITION_SETUP - Generate a global data structure 
% to support reporting for condition coverage.

% Copyright 1990-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2005/12/19 07:55:36 $

    global gcondition;
    
    gcondition = varargin{1}.metrics.condition;
    
    for i=2:length(varargin)
        gcondition = [gcondition varargin{i}.metrics.condition];
    end
    
    
    

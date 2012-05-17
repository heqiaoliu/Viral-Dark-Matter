function report_decision_setup(varargin)
% DECISION_SETUP - Generate a global data structure 
% to support reporting for decision coverage.

% Copyright 1990-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2005/12/19 07:55:40 $

    global gdecision;
    
    gdecision = varargin{1}.metrics.decision;
    
    for i=2:length(varargin)
        gdecision = [gdecision varargin{i}.metrics.decision];
    end

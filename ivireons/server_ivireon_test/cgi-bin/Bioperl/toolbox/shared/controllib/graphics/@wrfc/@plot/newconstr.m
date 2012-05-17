function [out,constrClassTypes] = newconstr(this, keyword, CurrentConstr) 
% NEWCONSTR  method to present options to create a new requirement on a plot
%
% This is an abstract method that needs to be implemented by
% derived classes.
%

% Author(s): A. Stothert 20-Sep-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:32 $

%Indicate no requirements possible for this plot type
out              = [];
constrClassTypes = [];

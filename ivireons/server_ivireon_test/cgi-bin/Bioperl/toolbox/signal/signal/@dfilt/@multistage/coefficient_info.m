function [p,v] = coefficient_info(this)
%COEFFICIENT_INFO   

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:24:20 $

p = {'Number of Stages'};
v = {num2str(nstages(this))};

% [EOF]

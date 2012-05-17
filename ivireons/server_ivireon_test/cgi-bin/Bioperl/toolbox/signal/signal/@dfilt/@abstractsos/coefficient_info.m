function [p, v] = coefficient_info(this)
%COEFFICIENT_INFO   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:00:23 $

p = {'Number of Sections'};
v = {sprintf('%d', nsections(this))};

% [EOF]

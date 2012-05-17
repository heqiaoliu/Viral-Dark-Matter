function tf = secondfilter(this,var)
% SECONDFILTER 
% Checks if given variable should be included in the import browser
% The valid variables are:
%       opcond.OperatingPoint variables that have matching models.
%       vectors that match the number of states in the project.
%       Simulink state structures.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2004/11/18 23:55:14 $

if isa(var,'opcond.OperatingPoint') && (length(var) == 1)
    tf = true;
elseif isa(var,'double')
    tf = true;
elseif isa(var,'struct') && isfield(var,'time') && isfield(var,'signals') 
    tf = true;
else
    tf = false;
end

function b = isValidPort(this,PortIDs) 
% ISVALIDPORT check that ports are valid for this model
%
% b = this.isValidPort(PortIDs)
%
% Inputs:
%   PortIDs - a vector of modepack.PortID objects
% Outputs:
%   b - a vector of logicals indicating whether the passed ports are valid
%       for this model
 
% Author(s): A. Stothert 11-Dec-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/01/15 18:56:53 $

warning('modelpack:AbstractMethod', ...
   'Method needs to be implemented by subclasses.');
b = [];
     

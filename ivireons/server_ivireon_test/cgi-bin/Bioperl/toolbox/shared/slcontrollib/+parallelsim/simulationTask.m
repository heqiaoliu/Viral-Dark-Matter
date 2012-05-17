classdef simulationTask < handle
% SIMULATIONTASK class to aid parallel simulations
%
 
% Author(s): A. Stothert 11-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/09/15 20:47:05 $

properties(GetAccess = 'public', SetAccess = 'public')
   model               %Name of model to be simulated
   uniqueDir           %Unique directory where simulation is run
   origDir             %Original directory before running simulation
   paths               %Paths to add for simulation
   origModels          %List of models in memory before loading the model
end

end


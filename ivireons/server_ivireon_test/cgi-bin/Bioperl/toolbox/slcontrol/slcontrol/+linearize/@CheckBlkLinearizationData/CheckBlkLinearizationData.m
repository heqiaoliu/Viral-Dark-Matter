classdef CheckBlkLinearizationData < handle
% CHECKBLKLINEARIZATIONDATA class to collect data used for frequency  check
% block execution
%
% 
 
% Author(s): A. Stothert 16-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:53:42 $

properties
   %hPorts - vector of linio objects
   hPorts
   
   %hReqs - vector of requirement objects to evaluate
   hReqs
   
   %CachedOutput - double value with the cached output value for the block
   CachedOutput
   
   %LinEngine - CheckBlkExecutionEngine object
   LinEngine
   
   %LinAtZero - flag indicating should perform linearization at time zero
   LinAtZero
   
   %CurrentTime - simulation time, used to indicate when the linearization
   %              is performed
   CurrentTime
   
   %hViewData - handle to viewer data of the check block, is used to update 
   %            view when new linearization is computed
   hViewData
      
   %Options - structure with linearization options for the block
   Options
   
   %SaveInfo - structure with logging information for the block
   SaveInfo
end

methods
   function obj = CheckBlkLinearizationData(varargin)
      %CHECKBLKLINEARIZATIONDATA constructor
      %
      % obj = CheckBlkLinearizationData('Prop',Value,....)
      %
      
      for ct=1:2:numel(varargin)
         obj.(varargin{ct}) = varargin{ct+1};
      end
   end
end

end

function ConfigSetParameters = createDisableWarningParameters(~)
% CREATEDISABLEWARNINGPARAMETERS  Create a struct that is used to disable
% warnings.
 
% Author(s): John W. Glass 01-Jul-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.12.1 $ $Date: 2010/07/26 15:40:24 $

ConfigSetParameters = struct('AlgebraicLoopMsg','none',...
                         'SolverPrmCheckMsg','none',...
                         'UnconnectedInputMsg','none',...
                         'UnconnectedOutputMsg','none',...
                         'UnconnectedLineMsg','none');
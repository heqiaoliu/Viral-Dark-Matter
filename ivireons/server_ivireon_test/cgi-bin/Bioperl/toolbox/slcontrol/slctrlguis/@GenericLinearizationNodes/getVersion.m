function Version = getVersion 
% GETVERSION 
%
 
% Author(s): John W. Glass 14-Feb-2007
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/10/31 07:35:55 $

% Version 2.0 Update to handle SimMechanics state naming in state tables.
% Version 3.0 Operating point specification task options are now stored in
% the linoptions object instead of through the OptionsCharStruct.
% Version 4.0 Removal of java.lang.Object arrays in table node data.
% Replace with cell arrays.
Version = 4.0;
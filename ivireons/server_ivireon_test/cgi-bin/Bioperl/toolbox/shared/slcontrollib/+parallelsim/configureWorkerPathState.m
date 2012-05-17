function configureWorkerPathState 
% CONFIGUREWORKERPATHSTATE  static package function run on workers to
% ensure they're in the correct directory and have the rights path settings
%

% Needed because of, g469102
 
% Author(s): A. Stothert 05-Jun-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.12.1 $ $Date: 2008/07/14 17:12:00 $

if evalin('base','exist(''simWorker'',''var'')')
   simWorker = evalin('base','simWorker');
   cd(simWorker.uniqueDir)
   addpath(simWorker.origDir.dir)
end
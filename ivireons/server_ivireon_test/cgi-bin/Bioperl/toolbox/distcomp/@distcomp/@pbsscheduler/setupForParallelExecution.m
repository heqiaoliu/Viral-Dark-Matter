function setupForParallelExecution( pbs, type )
%setupForParallelExecution - set up options for submitting parallel jobs

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:51:10 $

% Set both ClusterOsType and ParallelSubmissionWrapperScript
pbs.pSetupForParallelExecution( type, true, true );
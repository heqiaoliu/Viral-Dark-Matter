function value = pSetClusterOsType( lsf, value )
; %#ok Undocumented
%pSetClusterOsType - maybe update the wrapper script
%   This method looks at the value of ParallelSubmissionWrapperScript and if
%   it thinks that it isn't consistent with the ClusterOsType,
%   it will automatically update the wrapper script to the default value.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2007/06/18 22:13:30 $

persistent warnedBefore
if isempty( warnedBefore )
    warnedBefore = false;
end

% In each of these two cases, we have no way of knowing what the right thing to
% do here is, so do nothing.
if isempty( lsf.ParallelSubmissionWrapperScript ) || strcmp( value, 'mixed' )
    return
end

% do we think the current wrapper script is suitable for a PC?
[junk1, junk2, ext] = fileparts( lsf.ParallelSubmissionWrapperScript ); %#ok

switch lower( ext )
  case {'.bat', '.exe', '.cmd'}
    scriptIsForPc = true;
  otherwise
    scriptIsForPc = false;
end

workerIsPc = strcmp( value, 'pc' );

if scriptIsForPc ~= workerIsPc
    if ~warnedBefore
        warning( 'distcomp:lsfscheduler:ChangingParallelScript', ...
                 ['The ParallelSubmissionWrapperScript is being automatically \n', ...
                  'updated to the default value for "%s" workers'], value );
        warnedBefore = true;
    end
    % Don't set the ClusterOsType, do set the wrapper script
    lsf.pSetupForParallelExecution( value, false, true );
end

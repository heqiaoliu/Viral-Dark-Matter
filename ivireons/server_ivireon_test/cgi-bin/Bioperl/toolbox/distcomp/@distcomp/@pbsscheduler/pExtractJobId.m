function jobId = pExtractJobId( pbs, cmdOut ) %#ok<INUSL>
; %#ok Undocumented

% pExtractJobId - extract the job identifier from the output of a "qsub" command

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:57 $

% jobId could be in one of two expected forms:
% 123[].server-name
% 123.server-name

% The second piece of the regexp must pick out valid (fully-qualified) server names
jobId = regexp( cmdOut, '[0-9\[\]]+\.[a-zA-Z0-9-\.]*', 'match', 'once' );

if isempty( jobId )
    warning( 'distcomp:pbsscheduler:couldntParseQsubOutput', ...
             'Failed to parse the job identifier from the qsub output: "%s"', ...
             cmdOut );
end
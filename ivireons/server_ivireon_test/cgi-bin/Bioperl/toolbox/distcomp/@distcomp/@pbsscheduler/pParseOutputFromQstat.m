function infoStruc = pParseOutputFromQstat( pbs )
; %#ok Undocumented

% Run "qstat -fB" to retrieve information about PBS

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:51:00 $

[FAILED, out] = pbs.pPbsSystem( 'qstat -fB' );

if FAILED
    iErrorBecauseCannotFindOrExecute( 'qstat', out );
end

% Trawl through the information. Expect the first line to contain "Server <hostname>"
[line1, rest] = strtok( out, sprintf( '\n' ) );
t = strtrim( regexp( line1, '(?<=^Server: )(.*)$', 'match', 'once' ) );
if ~isempty( t )
    infoStruc.server = t;
else
    error( 'distcomp:pbsscheduler:DefaultServer', ...
           ['Couldn''t interpret default server name from the output \n', ...
            'of ''qstat -fB''. Output was: \n%s'], out );
end

% Pick out other interesting things
for field = { 'pbs_version', 'default_queue' }
    exp = sprintf( '(?<=\\s*%s = )(\\S*)', field{1} );
    t = strtrim( regexp( rest, exp, 'match', 'once' ) );
    infoStruc.(field{1}) = t;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iErrorBecauseCannotFindOrExecute - throw an error because of failure to
% execute a given command.
function iErrorBecauseCannotFindOrExecute( cmd, out )
if ~distcomp.isExeOnPath( cmd )
    error('distcomp:pbsscheduler:UnableToFindService', ...
          ['findResource is reporting an error because ''%s'' is not on your path.\n' ...
           'Most likely this is because your computer is not set up as a client on a PBS cluster\n' ...
           'or the PBS scripts are not on your path.'], cmd );
else
    error('distcomp:pbsscheduler:UnableToFindService', ...
          'Error executing the PBS command ''%s''. The reason given is \n %s', cmd, out);
end


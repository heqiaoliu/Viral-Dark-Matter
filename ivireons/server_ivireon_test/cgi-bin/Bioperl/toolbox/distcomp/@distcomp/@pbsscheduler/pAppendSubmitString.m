function pAppendSubmitString( pbs, scriptFile, submitString )
; %#ok Undocumented

%pAppendSubmitString - simple helper to append the actual submission string
%used to a PBS script file.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2008/05/05 21:36:40 $

fh = fopen( scriptFile, 'at' );
if fh == -1
    error( 'distcomp:pbsscheduler:cantWriteScript', ...
           'An error occurred writing to script: "%s"', scriptFile );
end

switch pbs.ClusterOsType
  case 'pc'
    commentStart = 'REM ';
  case 'unix'
    commentStart = '# ';
  otherwise
    error( 'distcomp:pbsscheduler:internalError', ...
           'Internal error: PBS submission only supports ''pc'' or ''unix'' ClusterOsType' );
end

try
    fprintf( fh, '\n%sThis script was submitted with the following command line:\n', commentStart );
    fprintf( fh, '%s%s\n', commentStart, submitString );
    err = [];
catch exception
    err = exception;
end

fclose( fh );

if ~isempty( err )
    rethrow( err );
end

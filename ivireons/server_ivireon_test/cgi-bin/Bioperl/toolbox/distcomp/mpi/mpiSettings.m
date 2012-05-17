function mpiSettings( option, varargin )
%mpiSettings - set various options for MPI communication
%   mpiSettings( 'DeadlockDetection', 'on' ) turns on deadlock detection
%   during calls to labSend and labReceive. If deadlock is detected, a call
%   to labReceive may cause an error. Although it is not necessary to enable
%   deadlock detection on all labs, this is the most useful option. The
%   default value for DeadlockDetection depends on the context. It is 'off'
%   in the following situations:
%     - During the execution of a parallel job
%   It is 'on' in the following situations:
%     - In PMODE
%     - In SPMD blocks executed with an interactive matlabpool or a 
%       matlabpooljob
%   It is recommended that "pctRunOnAll" is used to change the
%   DeadlockDetection state for SPMD blocks.
%
%   mpiSettings( 'MessageLogging', 'on' ) turns on MPI message logging. The
%   default is 'off'. The default destination is the MATLAB command window.
%
%   mpiSettings( 'MessageLoggingDestination', 'CommandWindow' ) sends MPI
%   logging information to the MATLAB command window. If the task within a
%   parallel job is set to capture command window output, then the MPI
%   logging information will be present in the task's CommandWindowOutput
%   property.
%
%   mpiSettings( 'MessageLoggingDestination', 'stdout' ) sends MPI logging
%   information to the standard output for the MATLAB process (under DCT,
%   this information ends up in the MDCE service log file)
%
%   mpiSettings( 'MessageLoggingDestination', 'File', <fname> ) sends MPI
%   logging information to a particular file
%   
%   NOTE that setting the MessageLoggingDestination does not automatically
%   enable MessageLogging - a separate call is required to enable message
%   logging.
%
%   Examples:
%
%   % example 1 - in "jobStartup.m" for a parallel job
%   mpiSettings( 'DeadlockDetection', 'on' );
%   myLogFname = sprintf( '%s_%d.log', tempname, labindex );
%   mpiSettings( 'MessageLoggingDestination', 'File', myLogFname );
%   mpiSettings( 'MessageLogging', 'on' );
%
%   % example 2 - turn off Deadlock Detection for all subsequent SPMD blocks
%   pctRunOnAll mpiSettings DeadlockDetection off

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2008/11/24 14:57:15 $

% First off, check all args are strings - otherwise bail right now
error( nargchk( 1, 3, nargin, 'struct' ) );
for ii=1:length( varargin )
   if ~ischar( varargin{ii} )
      error( 'distcomp:mpiSettings:argvalue', ...
             'All arguments to mpiSettings must be chars - argument %d is "%s"', ...
             ii, class( varargin{ii} ) );
   end
end

if ~mpiInitialized
    % Being called on the client - ignore
    return;
end

switch lower( option )
 case {'deadlockdetection', 'messagelogging'}
   
   if nargin ~= 2
      error( 'distcomp:mpiSettings:numargs', ...
             'mpiSettings for %s must specify ''on'' or ''off''', ...
             option );
   end
   
   % Pick the args for mpigateway
   if strcmpi( option, 'deadlockdetection' )
      opts = {'dddon', 'dddoff'};
   else
      opts = {'logon', 'logoff'};
   end
   
   if ischar( varargin{1} )
      switch lower( varargin{1} )
       case 'on'
         mpigateway( opts{1} );
       case 'off'
         mpigateway( opts{2} );
       otherwise
         error( 'distcomp:mpiSettings:badargs', ...
                'Invalid setting for: %s - valid values are ''on'' or ''off''', option );
      end
   else
      error( 'distcomp:mpiSettings:badargs', ...
             'Invalid setting for: %s - valid values are ''on'' or ''off''', option );
   end
 case 'messageloggingdestination'
   if nargin < 2 || nargin > 3
      error( 'distcomp:mpiSettings:badargs', ...
             'mpiSettings( ''MessageLoggingDestination'', ... ) must be called with 2 or 3 arguments' );
   end

   switch lower( varargin{1} )
    case 'commandwindow'
      mpigateway( 'logcmdwindow' );
    case 'stdout'
      mpigateway( 'logstdout' );
    case 'file'
      if nargin ~= 3
         error( 'distcomp:mpiSettings:badargs', ...
                'mpiSettings( ''MessageLoggingDestination'', ''File'', ... ) must be called with 3 arguments' );
      end
      mpigateway( 'logfname', varargin{2} );
   end
 otherwise
   error( 'distcomp:mpiSettings:badargs', ...
          'Unknown command "%s" in mpiSettings', option );
end

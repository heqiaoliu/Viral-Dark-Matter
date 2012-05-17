function [name, alive] = dct_psname( pid )
%DCT_PSNAME - retrieve the name of a process from its PID
%   [name, alive] = DCT_PSNAME( pid ) retrieves the process name from the
%   system in a system-dependent way. If the pid is found not to be alive, then
%   the "alive" flag will be false, and the name will be empty.

%  Copyright 2006-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $    $Date: 2008/08/26 18:13:02 $ 

alive = dct_psfcns( 'isalive', pid );
name  = '';

if ~alive
    return;
end

if ispc
    % Use the dct_psfcns MEX file
    try
        name = dct_psfcns( 'winprocname', pid );
    catch err
        if dct_psfcns( 'isalive', pid )
            % Couldn't calculate name of living process
            error( 'distcomp:psname:ProcessNameError', ...
                   'The following error occurred while retrieving the name of process %d: %s', ...
                   pid, err.message );
        else
            alive = false;
            name  = '';
        end
    end
else
    
    % Attempt to avoid returning names like "[mpiexec]" as these are only
    % generated when the process name is in the unstable phase.
    MAX_RETRIES = 4;
    PAUSE_AMOUNT = 0.25;
    
    done = false;
    numTries = 0;
    
    while ~done
        [name, alive] = iUnixPsName( pid );
        numTries = numTries + 1;
        
        % If we've exceeded the max number of tries, or the pid isn't alive, bail
        % out straight away
        if numTries > MAX_RETRIES || ~alive
            done = true;
        else
            % We're done if the process is alive, there's a non-empty name, and the
            % first character of the name isn't '['
            done = ( alive && ...
                     ~isempty( name ) && ...
                     name(1) ~= '[' );
        end
        
        if ~done
            pause( PAUSE_AMOUNT );
        end
    end
end

% Finally, double-check whether the PID is alive
if ~dct_psfcns( 'isalive', pid )
    name = '';
    alive = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iUnixPsName - use the shell script to calculate the PID name
function [name, alive] = iUnixPsName( pid )
% Use the shell script
script = fullfile( toolboxdir('distcomp'), 'bin', 'util', 'psname.sh' );
cmd = sprintf( '"%s" %s %d', script, computer, pid );
[s,w] = system( cmd );
if s
    if dct_psfcns( 'isalive', pid )
        % Couldn't calculate name of living process
        error( 'distcomp:psname:ProcessNameError', ...
               'The following error occurred while retrieving the name of process %d: %s', ...
               pid, w );
    else
        % Couldn't calculate name of a process that no longer is alive
        name = '';
        alive = false;
    end
else
    % Name is returned as |||name|||
    c = regexp( w, '\|\|\|([^|]*)\|\|\|', 'tokens' );
    if isempty( c ) || numel( c ) ~= 1 || numel( c{1} ) ~= 1
        error( 'distcomp:psname:ProcessNameError', ...
               'Couldn''t interpret output from psname.sh: "%s"', w );
    end
    name = c{1}{1};
    alive = true;
end

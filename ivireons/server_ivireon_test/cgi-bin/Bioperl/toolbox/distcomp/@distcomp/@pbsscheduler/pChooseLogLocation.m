function [logArgs, relLoc, absLoc] = pChooseLogLocation( pbs, storage, job ) 
; %#ok Undocumented
% iChooseLogLocation - choose where to put the output log based, and build
% the command-line argument. Return both the relative and absolute log
% locations - the relative location might be empty

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:54 $

if isa( job, 'distcomp.simpleparalleljob' )
    trailPart = sprintf( 'Job%d.log', job.ID );
else
    trailPart = sprintf( 'Job%d.Task^array_index^.log', job.ID );
end


if isa(storage, 'distcomp.filestorage')
    absLoc = pbs.pJobSpecificFile( job, trailPart, true );
    relLoc = [job.pGetEntityLocation, '/' trailPart];

    % Things are somewhat complicated on PC *clients*. If the storage location
    % is within a UNC share, then the output file delivery simply doesn't
    % work correctly. Therefore, we must use a local directory to store the
    % job output.
    if ispc
        % Check to see if the absLoc returned is a UNC path
        if ~isempty( regexp( absLoc, '^\\\\', 'once' ) )
            % Ok, remap the absLoc, no relLoc
            relLoc = '';
            absLoc = sprintf( '%s.%s', ...
                              tempname, trailPart );
        end
    end
else
    relLoc = '';
    absLoc = sprintf( '%s.%s', ...
                      tempname, trailPart );
end    
logArgs = ['-o "' absLoc '"'];

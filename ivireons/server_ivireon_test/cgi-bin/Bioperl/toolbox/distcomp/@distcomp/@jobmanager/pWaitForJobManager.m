function pWaitForJobManager( jobmanager )
; %#ok Undocumented
% pWaitForJobManager waits until jobmanager can be contacted
%
% pWaitForJobManager( jm )

%  Copyright 2008 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $    $Date: 2008/10/02 18:40:37 $

% findResource does this if the jm can't be reached
ws = warning( 'off', 'distcomp:findresource:ServiceNotFound' );
onCleanup( @()warning(ws) );

waitInterval = 30;
while ~jobmanager.pCheckTwoWayCommunications
    % Look up again - Name and Hostname are held by locally by current proxy,
    % so we don't need remote call to get them. The magic of caching
    % will update thing as we want.
    foundJM = findResource( 'scheduler', 'type', 'jobmanager', ...
        'LookupURL', jobmanager.LookupURL, ...
        'Name',      jobmanager.Name );
    if isempty( foundJM )
        pause( waitInterval );
    else
        if isequal(foundJM, jobmanager)
            return
        else
            error( 'distcomp:jobmanager:JobManagerChanged', ...
                ['The jobmanager "%s" now refers to a different jobmanager. ',...
                 'This is probably because the jobmanager has been restarted using the -clean flag. ',...
                 'Please contact your cluster administrator for more information. '], jobmanager.Name );
        end
    end
end



function OK = pIsAcceptableBkillError(lsf, bkillString)
; %#ok Undocumented
%pIsAcceptableBkillError is this an expected bkill error message
%
%  pIsAcceptableBkillError(SCHEDULER, BKILLOUTPUT)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:37:52 $ 


OK = false;
% Job already finished is OK because we might be destroying or
% cancelling a job that has finished
OK = OK || ~isempty(regexp(bkillString, ': Job has already finished', 'once'));
% After a time LSF forgets about jobs - we don't. Thus LSF might be out
% of date with us.
OK = OK || ~isempty(regexp(bkillString, ': No matching job found', 'once'));
% LSF seems to incorrectly indicate an error when this is returned
OK = OK || ~isempty(regexp(bkillString, ': Operation is in progress', 'once'));


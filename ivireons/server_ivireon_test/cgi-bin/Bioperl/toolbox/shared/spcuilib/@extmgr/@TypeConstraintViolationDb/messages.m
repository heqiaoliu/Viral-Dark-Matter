function msgs = messages(this)
%MESSAGES Return formatted violation messages.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:54 $

msgs = ''; % state persists in nested function below

hViolation = find(this, '-depth', 1, '-isa', 'extmgr.TypeConstraintViolation');

N = length(hViolation);
if N > 0
    if N > 1
        plural = 's';
    else
        plural = '';
    end
    msgs = sprintf('%d configuration constraint violation%s found\n', N, plural);
    for indx = 1:N
        msgs = [msgs message(hViolation(indx))]; %#ok
    end
end

% [EOF]

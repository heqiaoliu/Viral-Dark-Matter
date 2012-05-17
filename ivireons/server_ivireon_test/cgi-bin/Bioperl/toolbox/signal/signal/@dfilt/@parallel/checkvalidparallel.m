function checkvalidparallel(this)
%CHECKVALIDPARALLEL   Check if parallel is valid and error if not.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:42:59 $

if ~isvalidparallel(this),
    error(generatemsgid('invalidParallel'),...
        'Parallel filters must have the same rate change factors in all stages.');
end

% [EOF]

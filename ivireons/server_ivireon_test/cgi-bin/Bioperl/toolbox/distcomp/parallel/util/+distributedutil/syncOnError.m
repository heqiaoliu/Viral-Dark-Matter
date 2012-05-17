function varargout = syncOnError(func, varargin)
%syncOnError Call a function on all labs, all labs error if one lab errors.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/29 08:23:31 $

err = false;
try
    [varargout{1:nargout}] = func(varargin{:});
catch exception
    err = true;
end
if gop(@or, err)
    labsThatFailed = [];
    if err
        labsThatFailed = labindex;
        returnedError = exception;
    end
    labsThatfailed = gcat(labsThatFailed);
    if ~err
        returnedError = MException('distcomp:parallel:errorOnOtherLabs', ...
                                   'Error on lab(s) [ %d ].', labsThatfailed);
    end
    throw(returnedError);
end

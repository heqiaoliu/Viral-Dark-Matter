function signalNames = util_get_signal_parts(signalFullPath)

%   Copyright 2009 The MathWorks, Inc.

    signalNames = regexp(signalFullPath,'(\s*\w*\s*)*\.{0,0}','match');
end
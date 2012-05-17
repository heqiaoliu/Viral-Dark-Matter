function b = isRunning(this)
%ISRUNNING True if the source is connected to a running model, movie, file.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/03/31 18:44:08 $

    b = this.State.isRunning;
end


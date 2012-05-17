function clearBuffer(this)
%CLEARBUFFER Clear the buffer.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:08 $

% Reset the buffer to empty.
this.OldDataBuffer = {};

% Delete all the lines.  xxx not sure if this should be done here or not.
if ishghandle(this.Lines)
    delete(this.Lines);
    this.Lines = [];
end

% [EOF]

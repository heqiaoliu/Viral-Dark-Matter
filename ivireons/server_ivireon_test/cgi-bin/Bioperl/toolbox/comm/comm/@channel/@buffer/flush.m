function y = flush(h);
%FLUSH  Flush buffer.
%   h  - Buffer object
%   y  - Buffer contents

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:15 $
 
% Can override this method in subclasses to do additional flushing
% operations, e.g., computing signal statistics.

y = h.buffer_flush;
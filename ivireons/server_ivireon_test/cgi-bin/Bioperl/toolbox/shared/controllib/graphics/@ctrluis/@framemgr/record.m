function record(h,T)
%RECORD  Records transaction.

%   Author: P. Gahinet  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:16:31 $

% Commit transaction
T.commit;

% Push onto Undo stack
h.EventRecorder.pushundo(T);

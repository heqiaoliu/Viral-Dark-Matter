function add2hist(h,HistoryLine)
%ADD2HIST  Adds entry to history record.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:17:03 $

h.History = [h.History ; {HistoryLine}];  

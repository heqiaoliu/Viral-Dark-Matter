function f = thisisstable(Hd)
%THISISSTABLE  True if filter is stable.
%   THISISSTABLE(Hd) returns 1 if discrete-time filter Hd is stable, and 0
%   otherwise. 
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/12 23:52:40 $

[msgid,msg] = warnsv(Hd);
if ~isempty(msg),
    warning(msgid,msg);
end

sosm = get(Hd, 'sosMatrix');

f = true;

for indx = 1:size(sosm, 1)
    f = all([f signalpolyutils('isstable',sosm(indx,4:6))]);
end

% [EOF]

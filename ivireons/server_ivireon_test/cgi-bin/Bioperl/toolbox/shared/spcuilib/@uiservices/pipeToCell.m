function c = pipeToCell(p)
%PIPETOCELL Convert pipe separated values to a cell array.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/27 19:55:59 $

% Based on dspblks/private/pipecell

if isempty(p),
   c={}; return
end

pidx = [find(p=='|') length(p)+1];
c = {p(1:pidx(1)-1)}; % Get first string
for i=2:length(pidx), % Get all remaining strings
   next_str = p(pidx(i-1)+1 : pidx(i)-1);
   if isempty(next_str),
      next_str='';  % prevent "Empty string: 1-by-0"
   end
   c{i} = next_str;
end


% [EOF]

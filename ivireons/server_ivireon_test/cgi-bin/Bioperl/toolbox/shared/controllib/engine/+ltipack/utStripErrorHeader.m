function msg = utStripErrorHeader(msg)
% Strips error message header introduced by UDD

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:07 $
i = findstr(msg,'</a>');
if ~isempty(i)
   msg = msg(i+5:end);
end
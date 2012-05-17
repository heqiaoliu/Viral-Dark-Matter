function str = rcinfo(this,RowName,ColName)
%RCINFO  Constructs data tip text locating component in axes grid.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:29 $
if isnumeric(RowName)
   % RowName = row index in axes grid. Display as Ch(*)
   RowName = sprintf('Ch(%d)',RowName);
end
str = sprintf('Channel: %s',RowName);

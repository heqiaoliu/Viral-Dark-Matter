function str = rcinfo(this,RowName,ColName)
%RCINFO  Constructs data tip text locating component in axes grid.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:23:26 $

if isnumeric(RowName)
   % RowName = row index in axes grid. Display as Out(*)
   RowName = sprintf('Out(%d)',RowName);
end
if isnumeric(ColName)
   % ColName = column index in axes grid. Display as In(*)
   ColName = sprintf('In(%d)',ColName);
end

if isempty(ColName)
   str = sprintf('Output: %s',RowName);
elseif isempty(RowName)
   str = sprintf('Input: %s',ColName);
else
   str = sprintf('I/O: %s to %s',ColName,RowName);
end
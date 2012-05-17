function strList = utGetPortNameList(this,ports)  %#ok<INUSL>
% UTGETPORTNAMELIST create comma separated string with names of ports
%
 
% Author(s): A. Stothert 13-Dec-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/01/15 18:57:00 $

strList = ports.getFullName;
if iscell(strList)
   strList = strList(:)';  %want a row vector
   commas = cell(size(strList));
   [commas{:}] = deal(',\t');
   commas{end} = '';
   strList = vertcat(strList,commas);
   strList = strcat(strList{:});
   strList = sprintf(strList); %Needed to process \t commands
end

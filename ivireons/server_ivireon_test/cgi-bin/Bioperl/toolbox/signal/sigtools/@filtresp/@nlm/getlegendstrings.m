function strs = getlegendstrings(hObj, varargin)
%GETLEGENDSTRINGS Returns the legend strings

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2004/12/26 22:18:55 $

strs = getlegendstrings(hObj.FilterUtils, varargin{:});

% % If 'full' is requested we do not want to delete the ':' so we skip its
% % index when we throw out ': Reference'.
% if nargin > 1,
%     skip = 1;
% else
%     skip = 0;
% end
% 
% indx = 1;
% 
% checkstr = ': Reference';
% 
% % Loop over the strings.  If ': Reference' is not there, delete it.
% while indx <= length(strs),
%     sndx = findstr(strs{indx}, checkstr);
%     if isempty(sndx),
%         strs(indx) = [];
%     else
%         strs{indx}(sndx+skip:sndx+length(checkstr)-1) = [];
%         indx = indx + 1;
%     end
% end

% [EOF]

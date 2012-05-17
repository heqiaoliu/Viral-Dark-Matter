function s = string(this, buffer)
%STRING Convert buffer contents to text string
%   H.STRING Convert the buffer context to a text string.
%
%   H.STRING(BUFFER) Convert BUFFER to a text string.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:43 $

if nargin < 2,      buffer = this.buffer; end
if ~iscell(buffer), buffer = {buffer};    end

indx = 1;
while indx <= length(buffer),
    if ~ischar(buffer{indx})
        buffer(indx) = [];
    else
        indx = indx + 1;
    end
end

if isempty(buffer),
    s = '';
else
    s = sprintf('%s\n', buffer{:});
    s(end) = [];
end

% [EOF]

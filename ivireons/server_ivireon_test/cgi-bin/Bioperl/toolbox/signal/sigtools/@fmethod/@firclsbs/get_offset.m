function offset = get_offset(this, offset)
%GET_OFFSET  Preget function for 'PassbandOffset' property

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:34 $

if isempty(offset)
    offset = [0 0];
end


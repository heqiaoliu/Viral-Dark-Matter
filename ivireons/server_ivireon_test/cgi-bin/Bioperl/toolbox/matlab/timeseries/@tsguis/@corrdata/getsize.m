function s = getsize(this)

% Copyright 2004-2008 The MathWorks, Inc.

Size = [size(this.CData) 1];
if ~isempty(this.CData)
    s = Size([3 2]);
else % Case draw to throw an exception since the lengths of the time series 
     % were incompatible
    s = [0 0];
end



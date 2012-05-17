function h = initObject(h, varargin)
%INITOBJECT Initialize object H to values stored in VARARGIN

% @doppler/@baseclass

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:36:42 $

% Find the number of leading numeric values.
nNumeric = 0;
for k=1:nargin-1
    if ~isnumeric(varargin{k})
        break
    end
    nNumeric = nNumeric + 1;
end

% Maximum number of numeric args allowed is 0
if (nNumeric > 0)
    error([getErrorId(h) ':InvalidArgs'],['Invalid usage. Type ''help %s'' ' ...
        'to see correct usage.'], lower(class(h)));
end

h = initPropValuePairs(h, varargin{:});

%-------------------------------------------------------------------------------

% [EOF]

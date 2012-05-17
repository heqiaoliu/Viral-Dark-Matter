function fraclnth = getfraclength(this, popup)
%GETFRACLENGTH Returns the fractional length

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/12/26 22:20:55 $

datatype = get(this, 'ExportType');
fraclnth = get(this, 'FractionalLength');

% If popup is specified then we do not want to use the suggested type.
if nargin ~= 2 & strcmpi(get(this,'selection'), 'suggested'),
    datatype = get(this, 'SuggestedType');
end

if any(strcmpi(datatype, {'double','single'})),
    fraclnth = [];
else
    indx   = strfind(datatype, 'int');
    length = str2num(datatype(indx+3:end));
    if isempty(fraclnth),
        fraclnth = length-1; 
    end
    fraclnth = min([length fraclnth]);
end

% [EOF]

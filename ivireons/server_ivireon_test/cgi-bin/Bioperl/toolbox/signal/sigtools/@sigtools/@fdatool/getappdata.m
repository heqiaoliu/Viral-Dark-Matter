function data = getappdata(hFDA,fieldname)
%GETAPPDATA  Get the specified data stored in appdata.
%   GETAPPDATA(hFDA, FIELDNAME) get the data specified by FIELDNAME
%   in hFDA's Application Data.

%   Author(s): R. Losada
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.4 $  $Date: 2009/05/23 08:17:05 $

error(nargchk(1,2,nargin,'struct'));

data = get(hFDA,'ApplicationData');
if nargin > 1,
    try
        data = data.(fieldname);
    catch ME %#ok<NASGU>
        data = [];
    end
end


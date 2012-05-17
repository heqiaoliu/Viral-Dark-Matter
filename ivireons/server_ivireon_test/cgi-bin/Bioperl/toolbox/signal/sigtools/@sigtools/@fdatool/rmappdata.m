function rmappdata(hFDA,fieldname)
%RMAPPDATA Remove application-defined data.
%   RMAPPDATA(HFDA, NAME) removes the application-defined data NAME,
%   from the object specified by handle HFDA.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:21:18 $

error(nargchk(2,2,nargin,'struct'));

data = get(hFDA,'ApplicationData');

data = rmfield(data,fieldname);

setappdata(hFDA,data);


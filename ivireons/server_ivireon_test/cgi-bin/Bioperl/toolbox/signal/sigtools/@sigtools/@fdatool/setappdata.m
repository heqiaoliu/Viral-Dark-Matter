function setappdata(hFDA,fieldname,val)
%SETAPPDATA  Set the specified data in appdata.
%   SETAPPDATA(hFDA, FIELDNAME, VALUE) sets the data VALUE in 
%   FIELDNAME of the Application Data associated with hFDA.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2007/12/14 15:21:22 $

error(nargchk(2,3,nargin,'struct'));

if nargin < 3,
	set(hFDA,'ApplicationData',fieldname);
	
else
	
	data = get(hFDA,'ApplicationData');
	
	data.(fieldname) = val;
	
	set(hFDA,'ApplicationData',data);
end



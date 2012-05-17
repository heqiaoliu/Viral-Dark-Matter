function value = getappdata(h, name)
%GETAPPDATA Get value of application-defined data.
%  VALUE = GETAPPDATA(H, NAME) gets the value of the
%  application-defined data with name specified by NAME in the
%  object with handle H.  If the application-defined data does
%  not exist, an empty matrix will be returned in VALUE.
%
%  VALUES = GETAPPDATA(H) returns all application-defined data
%  for the object with handle H.
%
%  See also SETAPPDATA, RMAPPDATA, ISAPPDATA.

%  Copyright 1984-2005 The MathWorks, Inc.
%  $Revision: 1.11.4.7 $  $Date: 2005/06/21 19:32:16 $
%  Built-in function.

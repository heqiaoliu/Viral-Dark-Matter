function obj = isetfield(obj, field, value)
%ISETFIELD Set serial port object internal fields.
%
%   OBJ = ISETFIELD(OBJ, FIELD, VAL) sets the value of OBJ's FIELD 
%   to VAL.
%
%   This function is a helper function for the concatenation and
%   manipulation of serial port object arrays. This function should
%   not be used directly by users.
%

%   MP 7-13-99
%   Copyright 1999-2009 The MathWorks, Inc. 
%   $Revision: 1.5.4.5 $  $Date: 2009/04/15 23:20:46 $

% Assign the specified field information.
try
    obj.(field) = value;
catch %#ok<CTCH>
   error('MATLAB:serial:isetfield:invalidFIELD', 'Unable to set the field: %s',field);
end



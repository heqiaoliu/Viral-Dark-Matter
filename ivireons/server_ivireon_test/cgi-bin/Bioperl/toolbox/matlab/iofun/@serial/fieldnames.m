function out = fieldnames(obj, flag) %#ok<INUSD>
%FIELDNAMES Get serial port object property names.
%
%   NAMES=FIELDNAMES(OBJ) returns a cell array of strings containing 
%   the names of the properties associated with serial port object, OBJ.
%   OBJ can be an array of serial port objects.
%

%   MP 3-14-02
%   Copyright 1999-2008 The MathWorks, Inc. 
%   $Revision: 1.1.4.4 $  $Date: 2008/05/19 23:18:05 $

if ~isa(obj, 'instrument')
    error('MATLAB:serial:fieldnames:invalidOBJ', 'OBJ must be an instrument object.');
end

% Error if invalid.
if ~all(isvalid(obj))
   error('MATLAB:serial:fieldnames:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

try
    out = fieldnames(get(obj));
catch %#ok<CTCH>
    error('MATLAB:serial:fieldnames:invalidOBJ', 'Instrument object array OBJ cannot mix instrument object types.');
end

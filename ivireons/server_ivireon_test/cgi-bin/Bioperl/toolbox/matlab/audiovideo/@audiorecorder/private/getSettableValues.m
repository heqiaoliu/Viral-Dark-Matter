function [propnames,props] = getSettableValues(obj)
%getSettableValues gets all the settable values of a audiorecorder object
%
%    getSettableValues(OBJ) returns the settable values of OBJ as a list of settable
%    property names and a cell array containing the values.
%
%    See Also: AUDIORECORDER/PRIVATE/RESETVALUES

%    JCS
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2007/07/26 19:29:33 $

propnames = fieldnames(set(obj.internalObj));

% The settable values of the valid audiorecorder object
props = get(obj.internalObj, propnames);



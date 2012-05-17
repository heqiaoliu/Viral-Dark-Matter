%SET    Set MATLAB object property values.
%   SET(H,'PropertyName',PropertyValue) sets the value of the specified 
%   property for the MATLAB object with handle H.  If H is an array of 
%   handles, the specified property's value is set for all objects in H.  
%
%   SET(H,'PropertyName1',Value1,'PropertyName2',Value2,...) sets multiple
%   property values with a single statement. 
%
%   SET(H,pn,pv) sets the named properties specified in the cell array of
%   strings pn to the corresponding values in the cell array pv for all
%   objects specified in H.  The cell array pn must be 1-by-N, but the cell
%   array pv can be M-by-N where M is equal to length(H), so that each
%   object will be updated with a different set of values for the list of
%   property names contained in pn.
%
%   Given S a structure whose field names are object property names, 
%   SET(H,S) sets the properties identified by each field name of S with
%   the values contained in the structure.
%
%   A = SET(H, 'PropertyName') returns the possible values for the 
%   specified property of the object with handle H.  The returned array
%   is a cell array of possible value strings or an empty cell array if
%   the property does not have a finite set of possible string values.
%   
%   SET(H,'PropertyName') displays the possible values for the specified
%   property of object with handle H.  
%
%   Note that it is permissible to use property/value string pairs, 
%   structures, and property/value cell array pairs in the same call to
%   SET.
%
%   A = SET(H) returns all property names and their possible values for
%   the object with handle H.  H must be scalar.  The return value is a  
%   structure whose field names are the property names of H, and whose 
%   values are cell arrays of possible property values or empty cell .
%   arrays
%
%   SET(H) displays all properties and property values of scalar object H.  
%   The class can override the method SETDISP to control how this 
%   information is displayed. 
%
%   See also SET, HGSETGET, HGSETGET/SETDISP, HANDLE
 
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/03/02 22:17:09 $
%   Built-in function.

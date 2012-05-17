%GET Get memmapfile object properties.
%   GET(OBJ) displays all property names and their current values for
%   the memmapfile object OBJ.
%
%   V = GET(OBJ) returns a structure V where each field name is the
%   name of a property of OBJ and each corresponding field contains the value
%   of that property.
%
%   V = GET(OBJ, 'PropertyName') returns the value V of the specified 
%   property PropertyName for the memmapfile object OBJ.  Supported property
%   names are 'Format', 'Repeat', 'Offset', 'Writable', 'Data', and
%   'Filename'. See HELP MEMMAPFILE for a description of these properties.
%
%   V = GET(OBJ, PROPERTIES), where PROPERTIES is a 1-by-N cell array of
%   property names, returns a cell array V of property values corresponding
%   to PROPERTIES.
%
%   See also MEMMAPFILE, MEMMAPFILE/SUBSREF.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2006/06/20 20:10:17 $

%   Implemented in @memmapfile/memmapfile.m.

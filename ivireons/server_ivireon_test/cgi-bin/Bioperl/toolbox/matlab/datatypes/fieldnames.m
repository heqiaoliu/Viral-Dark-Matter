%FIELDNAMES Get structure field names.
%   NAMES = FIELDNAMES(S) returns a cell array of strings containing 
%   the structure field names associated with the structure s.
%
%   NAMES = FIELDNAMES(Obj) returns a cell array of strings containing 
%   the names of the fields in Obj if Obj is a MATLAB object, or the 
%   names of the public fields if Obj is a Java object.  MATLAB objects 
%   may override fieldnames and define their own behavior. 
%
%   NAMES = FIELDNAMES(Obj, '-full') returns a cell array of strings 
%   containing the name, type, attributes, and inheritance of each 
%   field associated with Obj, which is either a MATLAB or a Java object.
%   
%   See also ISFIELD, GETFIELD, SETFIELD, ORDERFIELDS, RMFIELD.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $  $Date: 2007/10/08 17:04:27 $
%   Built-in function.


function setArray(this,A)
%SETARRAY  Writes array value.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:35 $
try
   % Store array
   this.Storage.setArray(A,this.Variable);
catch
   % Write error
   error('Value of variable %s could not be written.',this.Variable.Name)
end

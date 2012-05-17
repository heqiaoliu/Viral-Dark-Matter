function A = getArray(this)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(ValueArray)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:33 $
try
   A = this.Storage.getArray(this.Variable);
catch 
   % Read error
   A = [];
end

function setArray(this,A,Variable)
%SETARRAY  Reads array value.
%
%   CONTAINER.SETARRAY(ValueArray,Variable)

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:10 $
S.(Variable.Name) = A;
try
   save(this.FileName,'-struct','S','-append')
catch
   save(this.FileName,'-struct','S')
end

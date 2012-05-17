function A = copy(this,DataCopy)
%COPY  Copy method for @BasicArray.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:13:54 $
A = hds.BasicArray;
A.GridFirst = this.GridFirst;
A.SampleSize = this.SampleSize;
A.Variable = this.Variable;
A.MetaData = copy(this.MetaData);
if DataCopy
   A.Data = this.Data;
end
function A = copy(this,DataCopy)
%COPY  Copy method for @LinkArray.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:13:59 $
A = hds.LinkArray;
A.Alias = this.Alias;
A.LinkedVariables = this.LinkedVariables;
A.SharedVariables = this.SharedVariables;
A.Transparency = this.Transparency;
if DataCopy
   A.Links = this.Links;
end

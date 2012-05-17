function Value = getData(this,fld)
% Return field from private Data object

%   Author: A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:44 $

%Wrapper method to retrieve properties from private data object
if ishandle(this.Data)
   Value = this.Data.(fld);
else
   %No data type defined
   tmpData = srorequirement.piecewisedata;
   Value = tmpData.(fld);
end
function c = getEdgeCount(this)
% GETEDGECOUNT  Method to return the number of edges stored in requirementdata
% object.
%
 
% Author(s): A. Stothert 02-May-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:31 $

c = size(this.xCoords,1);

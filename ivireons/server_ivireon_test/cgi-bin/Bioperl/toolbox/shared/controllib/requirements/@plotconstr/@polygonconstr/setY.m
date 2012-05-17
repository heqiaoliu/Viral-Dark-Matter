function setY(this,Value)
% Set private yCoords member

%   Author: A. Stothert
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:56 $

if ~(size(Value,2) == 2) ||...
      ~isa(Value,'double')
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errArgumentDimension','yCoords')
end
this.yCoords = Value;
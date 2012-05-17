function setX(this,Value)
% Set private xCoords member

%   Author: A. Stothert
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:54 $

if ~(size(Value,2) == 2) ||...
      ~isa(Value,'double')
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errArgumentDimension','xCoords')
end
this.xCoords = Value;
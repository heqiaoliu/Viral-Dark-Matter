function update(this)
% Fire event to notify listeners that data changed

%   Author: A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:35 $

this.send('DataChanged')
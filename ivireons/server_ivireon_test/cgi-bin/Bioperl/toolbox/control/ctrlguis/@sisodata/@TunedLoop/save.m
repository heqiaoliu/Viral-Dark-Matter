function Design = save(this)
%SAVE   Creates backup of TunedLoop data.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:39:30 $

Design = sisodata.TunedLoopSnapshot;

Design = utStoreTunedLoop(Design,this);
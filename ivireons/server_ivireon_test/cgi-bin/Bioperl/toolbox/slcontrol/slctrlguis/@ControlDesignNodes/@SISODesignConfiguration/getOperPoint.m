function op = getOperPoint(this) 
% GETOPERPOINT  Get the operating point from the SISODesignConfiguration
% Task.
%
 
% Author(s): John W. Glass 23-Sep-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/11/17 14:04:01 $

opnode = intersect(this.getChildren, ...
    [this.find('-class','OperatingConditions.ControlDesignOperConditionValuePanel','-depth',1);...
     this.find('-class','OperatingConditions.ControlDesignOperPointSnapshotPanel','-depth',1)]);

op = getOperPoint(opnode);
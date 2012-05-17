function this = sdodata(sdoObj,sigName)
%SDODATA constructor for the sdodata class 
    
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2008/11/13 17:56:49 $
   
   
this = fxptds.sdodata;
this.daobject = sdoObj;
this.path = sigName;


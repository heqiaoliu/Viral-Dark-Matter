%META.PROPERTY    Describe a property of a MATLAB class
%    The META.PROPERTY class contains descriptive information about 
%    properties of MATLAB classes.  Properties of a META.PROPERTY instance 
%    correspond to attributes of the class property being described.  
%
%    All META.PROPERTY properties are read-only.  The META.PROPERTY
%    instance can be queried to obtain information about the class
%    property it describes.  All information about class properties are
%    specified in the class definition for the class to which the property 
%    belongs.
%
%    Obtain a META.PROPERTY instance from the PROPERTIES property of the
%    META.CLASS instance.  PROPERTIES is a cell array of META.PROPERTY
%    instances, one per class property.
%    
%    %Example 1
%    e = MException('msg:id','text');
%    mc = metaclass(e);
%    mprop = mc.Properties;
%    properties(mprop{1});
%
%    %Example 2
%    mc = ?MException;
%    mprop = mc.Properties;
%    for i=1:numel(mprop)
%        mprop{i}.Name
%    end
%    
%    See also META.CLASS, META.METHOD, META.EVENT

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:08:55 $
%   Built-in class.
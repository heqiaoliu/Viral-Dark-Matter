%META.METHOD    Describe a method of a MATLAB class
%    The META.METHOD class contains descriptive information about 
%    methods of MATLAB classes.  Properties of a META.METHOD instance 
%    correspond to attributes of the class method being described.  
%
%    All META.METHOD properties are read-only.  The META.METHOD
%    instance can be queried to obtain information about the class
%    method it describes.  All information about class methods are
%    specified in the class definition for the class to which the method 
%    belongs.
%
%    Obtain a META.METHOD instance from the METHODS property of the
%    META.CLASS instance.  METHODS is a cell array of META.METHOD
%    instances, one per class method.
%
%    
%    %Example 1
%    %Display the properties of a META.METHOD instance
%    e = MException('msg:id','text');
%    mc = metaclass(e);
%    mmethods = mc.Methods;
%    properties(mmethods{1});
%
%    %Example 2
%    %Iterate over the META.METHOD instance for class MEXCEPTION and
%    %display each method's name.
%    mc = ?MException;
%    mmethods = mc.Methods;
%    for i=1:numel(mmethods)
%        mmethods{i}.Name
%    end
%
%    %Example 3
%    %Use the DEFININGCLASS property of META.METHOD to obtain the
%    %META.CLASS for the class to which the method belongs.
%    mc = ?MException;
%    mmethods = mc.Methods;
%    mc2 = mmethods{1}.DefiningClass;
%    mc == mc2
%    
%    See also META.CLASS, META.PROPERTY, META.EVENT

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:08:51 $
%   Built-in class.
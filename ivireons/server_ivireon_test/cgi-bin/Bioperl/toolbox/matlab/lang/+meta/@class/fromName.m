%FROMNAME    Obtain META.CLASS for specified class name
%    METACLS = META.CLASS.FROMNAME(CLASSNAME) returns the META.CLASS
%    object associated with the named class.  CLASSNAME must be a
%    string.  If CLASSNAME is contained within a package, you must provide
%    the fully qualified name.
%
%    %Example 1: Obtain the META.CLASS instance for class HANDLE
%    mc = meta.class.fromName('handle');
%
%    %Example 2: Obtain the META.CLASS instance for class META.EVENT using
%    %the fully qualified classname
%    mc = meta.class.fromName('meta.event');
%    
%    See also META.PACKAGE, METACLASS

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:08:49 $
%   Built-in method.
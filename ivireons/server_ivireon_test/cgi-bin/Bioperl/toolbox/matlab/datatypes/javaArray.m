%javaArray  Construct a Java Array Object
%   JA = javaArray(CLASSNAME,DIM1,...) returns a Java array object
%   (an object with Java dimensionality), the component class of which
%   is the Java class specified by the character string CLASSNAME.
%
%   Examples
%     % create a 10-element java.awt.Frame Java array
%     ja = javaArray('java.awt.Frame',10);
%     % create a 5x10x2 java.lang.Double Java array
%     ja = javaArray('java.lang.Double',5,10,2);

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2005/06/21 19:25:11 $


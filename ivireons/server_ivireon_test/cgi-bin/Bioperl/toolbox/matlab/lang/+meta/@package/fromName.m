%FROMNAME    Obtain META.PACKAGE for specified package name
%    METAPACK = META.PACKAGE.FROMNAME(PACKAGENAME) returns the META.PACKAGE
%    object associated with the named package.  PACKAGENAME must be a
%    string.  If PACKAGENAME is a nested package, you must provide the
%    fully qualified name.
%
%    %Example: Obtain the META.PACKAGE instance for package META using
%    %the package name.
%    mp = meta.package.fromName('meta');
%    
%    See also META.PACKAGE, META.PACKAGE.GETALLPACKAGES

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:08:52 $
%   Built-in method.
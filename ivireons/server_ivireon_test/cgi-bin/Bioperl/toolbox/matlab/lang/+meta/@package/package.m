%META.PACKAGE    Describe a MATLAB package
%    The META.PACKAGE class contains descriptive information about MATLAB
%    packages.  Properties of a META.PACKAGE instance correspond to 
%    attributes of the MATLAB package being described.  All META.PACKAGE
%    properties are read-only.
%    
%    Packages can contain classes, functions, and other packages, known as
%    nested packages.  If a package is nested, the CONTAININGPACKAGE 
%    property of META.PACKAGE can be used to obtain the META.PACKAGE 
%    instance for the parent package.  If a package is not nested, an empty
%    META.PACKAGE instance is returned.
%
%    %Example 1
%    %Use the static method GETALLPACKAGES of the META.PACKAGE class to 
%    %obtain META.PACKAGE instances for all top-level packages. 
%    all = meta.package.getAllPackages;
%    for i = 1:numel(all)
%        all{i}.Name
%    end
%
%    %Example 2
%    %Obtain the META.CLASS instances for all classes in package EVENT.  We
%    %obtain the META.PACKAGE for EVENT using class EVENT.LISTENER.
%    mc = ?event.listener;
%    mp = mc.ContainingPackage;
%    eventClasses = mp.Classes;
%    for i=1:numel(eventClasses)
%        eventClasses{i}.Name
%    end
%
%    PACKAGE methods:
%        fromName - return META.PACKAGE object for named package
%        getAllPackages - get all top-level packages
%
%    See also META.CLASS, META.PROPERTY, META.METHOD, META.EVENT

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2008/03/24 18:08:54 $
%   Built-in class.
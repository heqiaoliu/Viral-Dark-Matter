function names = getConstantNames()
%netcdf.getConstantNames Return list of constants known to netCDF library.
%   names = netcdf.getConstantNames() returns a list of names of netCDF 
%   library constants, definitions, and enumerations.  When these 
%   strings are supplied as actual parameters to the netCDF package 
%   functions, they will automatically be converted to the appropriate 
%   numeric value.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.create, netcdf.defVar, netcdf.open, 
%   netcdf.setDefaultFormat, netcdf.setFill.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/04/15 15:25:16 $

names = netcdflib('getConstantNames');
names = sort(names);


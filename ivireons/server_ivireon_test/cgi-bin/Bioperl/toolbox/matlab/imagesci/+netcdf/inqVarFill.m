function [noFillMode,fillValue] = inqVarFill(ncid,varid)
%netcdf.inqVarFill Return fill parameters for netCDF variable.
%   [noFillMode,fillValue] = netcdf.inqVarFill(ncid,varid) returns the 
%   no-fill mode and the fill value itself for the variable varid.  
%   ncid identifies the file or group.
%
%   This function corresponds to the "nc_inq_var_fill" function in the 
%   netCDF library C API.  
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       varid = netcdf.inqVarID(ncid,'temperature');
%       [noFillMode,fillValue] = netcdf.inqVarFill(ncid,varid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVarFill, netcdf.setFill.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2010/04/15 15:25:36 $

[noFillMode,fillValue] = netcdflib('inqVarFill',ncid,varid);

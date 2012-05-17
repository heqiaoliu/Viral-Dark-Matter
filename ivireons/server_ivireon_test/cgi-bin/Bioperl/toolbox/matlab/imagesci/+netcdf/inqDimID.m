function dimid = inqDimID(ncid,dimname)
%netcdf.inqDimID Return dimension ID.
%   dimid = netcdf.inqDimID(ncid,dimname) returns the ID of a dimension
%   given the name.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide".  This function 
%   corresponds to the "nc_inq_dimid" function in the netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       dimid = netcdf.inqDimID(ncid,'x');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqDim.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6.2.1 $ $Date: 2010/06/24 19:34:28 $

dimid = netcdflib('inqDimID', ncid,dimname);            

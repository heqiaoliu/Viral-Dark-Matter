function childGrpId = inqNcid(ncid,childGroupName)
%netcdf.inqNcid Return ID of named group.
%   childGroupId = netcdf.inqNcid(ncid,childGroupName) returns the ID of 
%   the named child group in the group specified by ncid.
%
%   This function corresponds to the "nc_inq_ncid" function in the 
%   netCDF library C API.  
%
%   Example:
%       ncid = netcdf.open('example.nc','nowrite');
%       gid = netcdf.inqNcid(ncid,'grid1');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqGrpName, netcdf,inqGrpNameFull.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:42:01 $

childGrpId = netcdflib('inqNcid',ncid,childGroupName);

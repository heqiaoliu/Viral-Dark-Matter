function groupName = inqGrpName(ncid)
%netcdf.inqGrpName Return relative name of group.
%   groupName = netcdf.inqGrpName(ncid) returns the name of a group
%   specified by ncid.  The root group will have name '/'.  
%
%   This function corresponds to the "nc_inq_grpname" function in the
%   netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','nowrite');
%       name = netcdf.inqGrpName(ncid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqGrpNameFull.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2010/04/15 15:25:26 $

groupName = netcdflib('inqGrpName',ncid);

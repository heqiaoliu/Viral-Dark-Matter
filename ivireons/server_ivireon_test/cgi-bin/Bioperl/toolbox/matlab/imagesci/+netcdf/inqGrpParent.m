function parentNcid = inqGrpParent(childNcid)
%netcdf.inqGrpParent Return ID of parent group.
%   parentGroupID = netcdf.inqGrpParent(ncid) returns the ID of the parent 
%   group given the location ncid of the child group.  
%
%   This function corresponds to the "nc_inq_grp_parent" function in the
%   netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       gid = netcdf.inqNcid(ncid,'grid2');
%       parentId = netcdf.inqGrpParent(gid);
%       fullName = netcdf.inqGrpNameFull(parentId);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqGrps.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2010/04/15 15:25:28 $

parentNcid = netcdflib('inqGrpParent',childNcid);

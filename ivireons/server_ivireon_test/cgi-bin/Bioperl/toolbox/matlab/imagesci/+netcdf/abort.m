function abort(ncid)
%netcdf.abort Revert recent netCDF file definitions.
%   netcdf.abort(ncid) will revert a netCDF file out of any definitions
%   made after netcdf.create but before netcdf.endDef.  The file will
%   also be closed.
%
%   This function corresponds to the function "nc_abort" in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.create, netcdf.endDef.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2010/04/15 15:25:01 $

netcdflib('abort',ncid);

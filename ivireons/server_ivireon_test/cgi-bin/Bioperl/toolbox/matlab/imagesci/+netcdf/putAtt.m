function putAtt(ncid,varid,attname,attvalue)
%netcdf.putAtt Write netCDF attribute.
%   netcdf.putAtt(ncid,varid,attrname,attrvalue) writes an attribute
%   to a netCDF variable specified by varid.  In order to specify a 
%   global attribute, use netcdf.getConstant('GLOBAL') for the varid.  
%
%   This function corresponds to the "nc_put_att" family of functions in 
%   the netCDF library C API.
%
%   Example:
%       ncid = netcdf.create('myfile.nc','CLOBBER');
%       varid = netcdf.getConstant('GLOBAL');
%       netcdf.putAtt(ncid,varid,'creation_date',datestr(now));
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.getAtt, netcdf.getConstant.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/04/15 15:25:42 $

fmt = netcdf.inqFormat(ncid);

% Determine the xtype (datatype) and attribute data parameters.
% Get the datatype from the class of data.
switch ( class(attvalue) )
  case 'double' 
    xtype = netcdf.getConstant('double');
  case 'single' 
    xtype = netcdf.getConstant('float');
  case 'int64' 
    xtype = netcdf.getConstant('int64');
  case 'uint64' 
    xtype = netcdf.getConstant('uint64');
  case 'int32' 
    xtype = netcdf.getConstant('int');
  case 'uint32' 
    xtype = netcdf.getConstant('uint');
  case 'int16' 
    xtype = netcdf.getConstant('short');
  case 'uint16' 
    xtype = netcdf.getConstant('ushort');
  case 'int8'
    xtype = netcdf.getConstant('byte');
  case 'uint8' 
    if strcmp(fmt,'FORMAT_CLASSIC') || strcmp(fmt,'FORMAT_64BIT')      
        xtype = netcdf.getConstant('byte');
    else
        xtype = netcdf.getConstant('ubyte');
    end
  case 'char' 
    xtype = netcdf.getConstant('char');
  otherwise 
    error('MATLAB:netcdf:putAtt:invalidDatatype', ... 
          'The datatype %s is not allowed with %s.', ... 
          class(attvalue), mfilename );
end



% Determine the correct function string.
switch ( class(attvalue) ) 
  case 'double' 
    funstr = 'putAttDouble'; 
  case 'single'
    funstr = 'putAttFloat'; 
  case 'int64' 
    funstr = 'putAttInt64'; 
  case 'uint64' 
    funstr = 'putAttUint64'; 
  case 'int32' 
    funstr = 'putAttInt'; 
  case 'uint32' 
    funstr = 'putAttUint'; 
  case 'int16' 
    funstr = 'putAttShort'; 
  case 'uint16' 
    funstr = 'putAttUshort'; 
  case 'int8' 
    funstr = 'putAttSchar'; 
  case 'uint8' 
    if strcmp(fmt,'FORMAT_CLASSIC') || strcmp(fmt,'FORMAT_64BIT')      
        funstr = 'putAttUchar'; 
    else
        funstr = 'putAttUbyte'; 
    end
  case 'char' 
    funstr = 'putAttText'; 
  otherwise 
    error('MATLAB:netcdf:putAtt:badDatatype', ... 
          'The datatype %s is not allowed with %s.', ...
          class(attvalue), mfilename ); 
end



% Invoke the correct netCDF library routine.
if ischar(attvalue)
    netcdflib('putAttText',ncid,varid,attname,attvalue);
else
    netcdflib(funstr,ncid,varid,attname,xtype,attvalue);
end



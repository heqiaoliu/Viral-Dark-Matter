function h5attput ( h5file, varargin )
% H5ATTPUT    Add HDF5 attribute to existing file.
%
%   H5ATTPUT(HDFFILE,VARNAME,ATTNAME,ATTVALUE) creates/overwrites the
%   attribute named ATTNAME with the value ATTVALUE.  The parent object
%   VARNAME can be either an HDF5 variable or group.  VARNAME must be a
%   complete pathname. 
%
%   H5ATTPUT(HDFFILE,ATTNAME,ATTVALUE) does the same thing, but the
%   complete path to the parent object is embedded within ATTNAME.
%
%   Simple strings will be created in a scalar dataspace.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/24 14:58:59 $


error(nargchk(3,4,nargin,'struct'));
error(nargoutchk(0,0,nargout,'struct'));

[varname, attname, attvalue] = parse_and_validate_inputs ( h5file, varargin{:} );

flags = 'H5F_ACC_RDWR';
plist_id = 'H5P_DEFAULT';

file_id = H5F.open ( h5file, flags, plist_id );

[parent_id, parent_obj_is_group] = set_parent_id ( file_id, varname );
dataspace_id                     = set_dataspace_id ( attvalue );
datatype_id                      = set_datatype_id ( attvalue );
att_id                           = set_attribute_id ( parent_id, attname, datatype_id, dataspace_id );


H5A.write(att_id,datatype_id,attvalue);

H5T.close(datatype_id);
H5S.close(dataspace_id);
H5A.close(att_id);

if parent_obj_is_group
	H5G.close(parent_id);
else
	H5D.close(parent_id);
end

H5F.close(file_id);


%===============================================================================
% SET_ATTRIBUTE_ID
%
% Setup the attribute ID.  We need to check as to whether or not the attribute
% already exists.
function att_id = set_attribute_id ( parent_id, attname, datatype_id, dataspace_id )

try
	att_id = H5A.open_name ( parent_id, attname );
catch
	att_id = H5A.create ( parent_id, attname, datatype_id, dataspace_id,'H5P_DEFAULT' );
end


%===============================================================================
% SET_DATASPACE_ID
%
% Setup the dataspace ID.  This just depends on how many elements the 
% attribute actually has.
function dataspace_id = set_dataspace_id ( attvalue )

if ischar(attvalue)
	dataspace_id = H5S.create('H5S_SCALAR');
else
    dims = size(attvalue);
    
    if (dims(1) ~= numel(attvalue))
        rank = ndims(attvalue);
        dims = fliplr(size(attvalue));
    else
        rank = 1;
        dims = dims(1);
    end
    
	dataspace_id = H5S.create_simple ( rank, dims, dims );
end


%===============================================================================
% SET_PARENT_ID
%
% If the given variable is "/", then we know we are creating a group attribute.
% Otherwise try to open the variable as a dataset.  If that fails, then it
% must be a subgroup.
function [parent_id, parent_obj_is_group] = set_parent_id ( file_id, varname )
if strcmp(varname,'/')
    parent_obj_is_group = true;
    parent_id = H5G.open ( file_id, varname );
else
    try
        parent_id=H5D.open(file_id,varname);
    	parent_obj_is_group = false;
    catch
        parent_id = H5G.open ( file_id, varname );
    	parent_obj_is_group = true;
    end
end

%===============================================================================
% SET_DATATYPE_ID
%
% We need to choose an appropriate HDF5 datatype based upon the attribute
% data.
function datatype_id = set_datatype_id ( attvalue )
switch class(attvalue)
	case 'double'
	    datatype_id = H5T.copy('H5T_NATIVE_DOUBLE');
	case 'single'
	    datatype_id = H5T.copy('H5T_NATIVE_FLOAT');
	case 'int64'
	    datatype_id = H5T.copy('H5T_NATIVE_LONG');
	case 'uint64'
	    datatype_id = H5T.copy('H5T_NATIVE_ULONG');
	case 'int32'
	    datatype_id = H5T.copy('H5T_NATIVE_INT');
	case 'uint32'
	    datatype_id = H5T.copy('H5T_NATIVE_UINT');
	case 'int16'
	    datatype_id = H5T.copy('H5T_NATIVE_SHORT');
	case 'uint16'
	    datatype_id = H5T.copy('H5T_NATIVE_USHORT');
	case 'int8'
	    datatype_id = H5T.copy('H5T_NATIVE_SCHAR');
	case 'uint8'
	    datatype_id = H5T.copy('H5T_NATIVE_UCHAR');
	case 'char'
	    datatype_id = H5T.copy('H5T_C_S1');
		H5T.set_size(datatype_id,length(attvalue));
		H5T.set_strpad(datatype_id,'H5T_STR_NULLTERM');
	otherwise 
		error('MATLAB:H5ATTPUT:unsupportedDatatype', ...
		       '''%s'' is not a supported H5ATTPUT datatype.\n', class(attvalue) );
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARSE_AND_VALIDATE_INPUTS
%
% The VARNAME and ATTNAME values may need to be parsed from one of the inputs,
% and all but the ATTVALUE input must have their datatypes checked.
function [varname,attname,attvalue] = parse_and_validate_inputs(hfile,varargin)

if ~ischar(hfile)
	error('MATLAB:H5ATTPUT:badDatatype', ...
	      'Filename input argument must have datatype char.' );
end

if nargin == 3
	varname = varargin{1};
	attvalue = varargin{2};

    slashes = findstr ( varname, '/' );
    if isempty(slashes)
        error ( 'MATLAB:H5ATTGET:badAttributePath', ...
                'Could not parse the given attribute path, ''%s''', varname );
    elseif slashes == 1

        %
        % case of "/attname" is different than "/path/to/attname"
        attname = varname(2:end);
        varname = varname(1);

    else
        attname = varname(slashes(end)+1:end);
        varname = varname(1:slashes(end)-1);
    end

else
	varname = varargin{1};
	attname = varargin{2};
	attvalue = varargin{3};
end

if ~ischar(varname)
	error('MATLAB:H5ATTPUT:badDatatype', ...
	      'VARNAME input argument must have datatype char.' );
end

if ~ischar(attname)
	error('MATLAB:H5ATTPUT:badDatatype', ...
	      'ATTNAME input argument must have datatype char.' );
end



return

function file_id = open(filename,flags,fapl)
%H5F.open  Open HDF5 file.
%   file_id = H5F.open(name,flags,fapl_id) opens the file specified by 
%   name, returning the file identifier, file_id. flags specifies file 
%   access flags and can be specified by one of the following strings
%   or their numeric equivalents:
%
%       'H5F_ACC_RDWR'   - read-write mode
%       'H5F_ACC_RDONLY' - read-only mode
%
%   fapl_id is the identifier of the file access property list. 
%
%   Example:  
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       H5F.close(fid);
%
%  See also H5F, H5F.close, H5ML.get_constant_value.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/04/15 15:20:34 $

% Get the full path name.
fid = fopen(filename,'r');
if fid == -1

	% If the filename has a regular expression pattern in it,
	% it is most likely intended to be used with the family driver.
	if isempty(regexp(filename,'%[ud]', 'once'))
    	error('MATLAB:H5Fopen:fileOpenFailure', ...
    	    'Unable to open the file %s.', filename);
	end

else

	% Ok, no regular expression, assume a single file.
	% Get the full path name.
    filename = fopen(fid);
    fclose(fid);

end


id = H5ML.unwrap_ids(fapl);
file_id = H5ML.hdf5lib2('H5Fopen', filename, flags, id);            
file_id = H5ML.id(file_id,'H5Fclose');

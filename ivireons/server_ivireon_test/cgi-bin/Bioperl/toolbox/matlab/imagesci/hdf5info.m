function info = hdf5info(filename, varargin)
%HDF5INFO Get information about an HDF5 file.
%   
%   FILEINFO = HDF5INFO(FILENAME) returns a structure whose fields contain
%   information about the contents of an HDF5 file.  FILENAME is a
%   string that specifies the name of the HDF file. 
% 
%   FILEINFO = HDF5INFO(..., 'ReadAttributes', BOOL) allows the user to
%   specify whether or not to read in the values of the attributes in
%   the HDF5 file.  The default value for BOOL is true.
%
%   [...] = HDF5INFO(..., 'V71Dimensions', BOOL) specifies whether to
%   report the dimensions of datasets and attributes as given in earlier
%   versions of HDF5INFO (MATLAB 7.1 [R14SP3] and earlier).  If BOOL is
%   true, the first two dimensions are swapped to imply a change in
%   majority.  This behavior may not correctly reflect the intent of the
%   data, but it is consistent with HDF5READ when it is also given the
%   'V71Dimensions' parameter.  When BOOL is false (the default), the
%   data dimensions correctly reflect the data ordering as it is written
%   in the file.  Each dimension in the output variable matches the same
%   dimension in the file.
%   
%   Please read the file hdf5copyright.txt for more information.
%
%   Example:
%
%       info = hdf5info('example.h5');
%
%   See also HDF5READ, HDF5WRITE, HDF5.

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.8 $  $Date: 2009/11/09 16:27:11 $

%
% Process arguments.
%

if (nargin < 1)
    error('MATLAB:hdf5info:notEnoughInputs', ...
          'HDF5INFO requires at least one input argument.')
end

if (nargout > 4)
    error('MATLAB:hdf5info:tooManyOutputs', ...
          'HDF5INFO requires four or fewer output arguments.')
end

[read_attribute_values, V71Dimensions, msg] = parse_inputs(varargin{:});
if (~isempty(msg))
    error('MATLAB:hdf5info:inputParsing', '%s', msg);
end

%
% Is the filename at least char?
if ~ischar(filename)
    error('MATLAB:hdf5info:filenameNotChar', ...
          'The filename argument must have datatype ''char''.' );
end


% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.h5']);
    
    if (fid == -1)
        fid = fopen([filename '.h5']);
    end
    
end

if (fid == -1)
    error('MATLAB:hdf5info:fileOpen', 'Couldn''t open file (%s).', filename)
else
    filename = fopen(fid);
    fclose(fid);
end

% Get file info and mode in which the file was opened.

d = dir(filename);

% Set the positions of the fields.
info.Filename = d.name;
info.LibVersion = '';
info.Offset = [];
info.FileSize = d.bytes;
info.GroupHierarchy = struct([]);

% Get the version of the library that wrote out the file, the offset, 
% and the group hierarchy!
[info.Offset, info.GroupHierarchy, majnum, minnum, relnum] = ...
    hdf5infoc(filename, read_attribute_values, V71Dimensions);

info.LibVersion = [num2str(majnum) '.' num2str(minnum) '.' num2str(relnum)];

% parse_inputs : get the name of the file and whether or not to read
% attribute values

function [read_attribute_values, V71Dimensions, msg] = ...
        parse_inputs(varargin)

read_attribute_values = true;
V71Dimensions = false;
msg = '';

% Parse arguments based on their number.
if (nargin > 0)
    
    paramStrings = {'readattributes',
                    'v71dimensions'};
    
    % For each pair
    for k = 1:2:length(varargin)
        param = lower(varargin{k});
            
        if (~ischar(param))
            msg = 'Parameter name must be a string.';
            return
        end
        
        idx = strmatch(param, paramStrings);
        
        if (isempty(idx))
            msg = sprintf('Unrecognized parameter name "%s".', param);
            return
        elseif (length(idx) > 1)
            msg = sprintf('Ambiguous parameter name "%s".', param);
            return
        end
        
        switch (paramStrings{idx})
        case 'readattributes'
           read_attribute_values = varargin{k+1};
           if ~islogical(read_attribute_values)
               msg = sprintf('''ReadAttributes'' must be a logical type.');
           end
        case 'v71dimensions'
           V71Dimensions = varargin{k+1};
           if ~islogical(V71Dimensions)
               msg = sprintf('''V71Dimensions'' must be a logical type.');
           end
        end
    end
end

function [data, attributes] = hdf5read(varargin)
%HDF5READ Reads data from HDF5 files.
%
%   HDF5READ reads data from a data set in an HDF5 file.  If the
%   name of the data set is known, then HDF5READ will search the file
%   for the data.  Otherwise, use HDF5INFO to obtain a structure
%   describing the contents of the file. The fields of the structure
%   returned by HDF5INFO are structures describing the data sets 
%   contained in the file.  A structure describing a data set may be
%   extracted and passed directly to HDF5READ.  These options are 
%   described in detail below.
%
%   DATA = HDF5READ(FILENAME,DATASETNAME) returns in the variable DATA
%   all data from the file FILENAME for the data set named DATASETNAME.  
%   
%   DATA = HDF5READ(FILENAME,LOCATION,ATTRIBUTENAME) returns in the 
%   variable DATA all data from the file FILENAME for the attribute named 
%   ATTRIBUTENAME attached to the location provided in LOCATION. Location 
%   can be either a dataset or a group.
%
%   DATA = HDF5READ(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDF5INFO (see example).
%
%   [DATA, ATTR] = HDF5READ(..., 'ReadAttributes', BOOL) returns the
%   data information for the data set as well as the associated attribute
%   information contained within that data set.  By default, BOOL is
%   false.
%
%   [...] = HDF5READ(..., 'V71Dimensions', BOOL) specifies whether to
%   change the majority of datasets.  If BOOL is true, the first two
%   dimensions of the dataset are permuted.  This behavior may not
%   correctly reflect the intent of the data and may invalidate metadata,
%   but it is consistent with previous versions of HDF5READ (MATLAB 7.1
%   [R14SP3] and earlier).  When BOOL is false (the default), the data
%   dimensions correctly reflect the data ordering as it is written in
%   the file.  Each dimension in the output variable matches the same
%   dimension in the file. 
%   
%   HDF5READ performs best on numeric datasets.  It is strongly recommended
%   that you use the low-level HDF5 interface when reading string, compound, 
%   or variable length datasets.  To read a subset of a dataset, you must
%   use the low-level interface.
%  
%   Example:
%
%     % Read a dataset based on an HDF5INFO structure.
%     info = hdf5info('example.h5');
%     dset = hdf5read(info.GroupHierarchy.Groups(2).Datasets(1));
%
%   Please read the file hdf5copyright.txt for more information.
%
%   See also HDF5INFO, HDF5WRITE, HDF5, H5D.READ.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.11 $  $Date: 2009/11/09 16:27:12 $

%
% Process arguments.
%
checkArgCounts(varargin{:})
settings = parse_inputs(varargin{:});

%
% Verify existence of filename.
%

% Get full filename.
fid = fopen(settings.filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([settings.filename '.h5']);
    
    if (fid == -1)
        fid = fopen([settings.filename '.h5']);
    end
    
end

if (fid == -1)
    error('MATLAB:hdf5read:fileOpen', ...
          'Couldn''t open file (%s).', ...
          settings.filename)
else
    settings.filename = fopen(fid);
    fclose(fid);
end

% Read the data
[data, attributes] = hdf5readc(settings.filename, ...
                               settings.datasetName, ...
                               settings.attributeName, ...
                               settings.readAttributes, ...
                               settings.V71Dimensions);



function checkArgCounts(varargin)

if (nargin < 1)
    error('MATLAB:hdf5read:notEnoughInputs', ...
          'HDF5READ requires at least one input argument.')
end

pvMsg = 'Incorrect input syntax: possible missing dataset/attribute or incomplete parameter-value pair.';

if (rem(nargin, 2) == 0)

    % Even: filename, dataset, param-value pairs, ...
    if  (isstruct(varargin{1}))
        error('MATLAB:hdf5read:paramMismatchStruct', pvMsg)
    end
end

% parse_paramvalues : Parse the param-value pairs
% 

function [V71Dimensions, readAttributes] = parse_paramvalues(varargin)

V71Dimensions = false;
readAttributes = false;

% Parse arguments based on their number.
if (nargin > 1)
    paramStrings = {'readattributes'
                    'v71dimensions'};

    % For each pair
    for k = 1:2:length(varargin)
        param = lower(varargin{k});
        if (~ischar(varargin{k}))
            error('MATLAB:hdf5read:inputParsing', 'Parameter name must be a string.');
        end
        
        idx = strmatch(param, paramStrings);
        
        if (isempty(idx))
            error('MATLAB:hdf5read:inputParsing', ...
                  'Unrecognized parameter name "%s".', param);
        elseif (length(idx) > 1)
            error('MATLAB:hdf5read:inputParsing', ...
                  'Ambiguous parameter name "%s".', param);
        end
        
        switch (paramStrings{idx})
        case 'readattributes'
            readAttributes = varargin{k+1};
            if ~islogical(readAttributes)
                error('MATLAB:hdf5read:inputParsing', ...
                      '''ReadAttributes'' must be a logical type.');
            end
        case 'v71dimensions'
          
            V71Dimensions = varargin{k+1};
            if ~islogical(V71Dimensions)
                error('MATLAB:hdf5read:inputParsing', ...
                      '''V71Dimensions'' must be a logical type.');
            end
        end
    end
end

% parse_inputs : get the name of the file, the dataset name, and
% whether or not to read attribute value 

function settings = parse_inputs(varargin)

settings.readAttributes = false;
settings.datasetName = '';
settings.attributeName = '';
settings.filename = '';
settings.V71Dimensions = false;

if ischar(varargin{1})
    settings.filename = varargin{1};

    if (nargin > 1)
        if ischar(varargin{2})
            settings.datasetName = varargin{2};       
            
            if rem(nargin, 2) ~= 0 % Odd arguments suggest attribute name
                if ~ischar(varargin{3})
                    error('MATLAB:hdf5read:inputParsing', ...
                          'Attribute name must be a char array' );
                end
                settings.attributeName = varargin{3};
                varargin = {varargin{4:end}};
            else
                varargin = {varargin{3:end}};
            end
        else
            error('MATLAB:hdf5read:inputParsing', ...
                 'Dataset name must be a char array' );
        end
    else
        error('MATLAB:hdf5read:inputParsing', ...
              'Dataset name not supplied with filename' );
    end
elseif isa(varargin{1}, 'struct')
    try
        hinfo = varargin{1};
        settings.filename = hinfo.Filename;
        if isfield(hinfo,'Location') % An attribute
            settings.datasetName = hinfo.Location;
            settings.attributeName = hinfo.Shortname;
        else
            settings.datasetName = hinfo.Name;
        end
        varargin = {varargin{2:end}};
    catch ME
        error('MATLAB:hdf5read:inputParsing', ...
              ['Input is not a scalar part of the info struct ' ...
               'returned by HDF5INFO']);
    end
else
    error('MATLAB:hdf5read:inputParsing', ...
          ['First input argument to HDF5READ must be a filename ' ...
           'or part of a valid info struct'] );
end

[settings.V71Dimensions, settings.readAttributes] = parse_paramvalues(varargin{:});


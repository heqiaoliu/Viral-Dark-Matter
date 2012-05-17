function data = hdfgridread(hinfo,fieldname,varargin)
%HDFGRIDREAD
%  
%   DATA=HDFGRIDREAD(HINFO,FIELD) reads data from the field FIELD of an
%   HDF-EOS Grid structure identified by HINFO.  
%   
%   DATA=HDFGRIDREAD(HINFO,FIELD,PARAM,VALUE,PARAM2,VALUE2,...) reads
%   data from an HDF-EOS grid structure identified by HINFO.  The data is
%   subset with the parameters PARAM,PARAM2,... with the particular type of
%   subsetting defined in SUBSET.  
%   
%   SUBSET may be any of the strings below, defined in HDFINFO:
%   
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%   
%   The 'Fields' subsetting method is required. The SUBSET methods 'Index',
%   'Tile', and 'Interpolate' and 'Pixels' are  exclusive.  They may not be
%   used with any other method of subsetting the Grid data.  'Time' may be used
%   alone, following 'Box', or following 'Vertical' subsetting.  'Vertical may
%   be used without previous subsetting, following 'Box' or 'Time' subsetting.
%   For example the following command 
%   
%   data=hdfgridread(hinfo,'Fields',fieldname,'Box',{long,lat},'Time',{1.1,1.2})
%   
%   will first subset the grid be defining a box region, then subset the grid
%   along the time period.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/11/09 16:27:32 $

data= [];
regionID = [];

%Verify inputs are valid
parseInputs(hinfo,fieldname,varargin{:});

%Open interfaces

fileID = hdfgd('open',hinfo.Filename,'read');
if fileID==-1
  error('MATLAB:hdfgridread:openInterface', ...
        'Unable to open Grid interface to read ''%s'' data set. Data set may not exist or file may be corrupt.',hinfo.Name);
end

gridID = hdfgd('attach',fileID,hinfo.Name);
if gridID==-1
  hdfgd('close',fileID);
  error('MATLAB:hdfgridread:attachInterface', ...
        'Unable to attach Grid interface to read ''%s'' data set. Data set may not exist or file may be corrupt.',hinfo.Name);
end

%Default
numPairs = length(varargin)/2;
if numPairs==0
  numPairs = 1;
  params = {'index'};
  values = {{[],[],[]}};
else
  params = varargin(1:2:end);
  values = varargin(2:2:end);
end

%Just in case
params = lower(params);

%Subset and read
for i=1:numPairs

    switch params{i}
        case 'index'
            data = get_grid_data_via_index (hinfo,fileID,gridID,fieldname,params{i},values{i});  
    
        case 'tile'
            data = get_grid_data_via_tiles (fileID,gridID,fieldname,params{i},values{i});  

        case 'pixels'
            data = get_grid_data_from_pixels (fileID,gridID,fieldname,params{i},values{i});  

        case 'interpolate'
            data = get_grid_data_from_interpolate (fileID,gridID,fieldname,params{i},values{i});  

        case 'box'
            regionID = get_grid_regionid_from_box (fileID,gridID,params{i},values{i});  

        case 'time'
            regionID = get_grid_regionid_from_time_period (fileID,gridID,regionID,params{i},values{i});  

        case 'vertical'
            regionID = get_grid_regionid_via_vertical(fileID,gridID,regionID,params{i},values{i});  

        otherwise
            closeGDInterfaces(fileID,gridID);
            error('MATLAB:hdfgridread:unknownSubsetMethod', ...
                    'Unrecognized subsetting method %s.',params{i});
    end

end



if (~isempty(regionID) && (regionID~=-1))
  try
    [data,status] = hdfgd('extractregion',gridID,regionID,fieldname);
    if status == -1
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:extractregionFailed', ...
                'extractregion operation failed.');
    end
  catch myException
    closeGDInterfaces(fileID,gridID);
    rethrow(myException);
  end
end

closeGDInterfaces(fileID,gridID);

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);


%=================================================================
function closeGDInterfaces(fileID,gridID)
%Close interfaces
try %#ok<TRYNC>
    hdfgd('detach',gridID);
end
try %#ok<TRYNC>
    hdfgd('close',fileID);
end


%=================================================================
function parseInputs(hinfo,fieldname,varargin)

if isempty(fieldname)
  error('MATLAB:hdfgridread:missingFieldsParam', ...
        'Must use ''Fields'' parameter when reading HDF-EOS Grid data sets.');
else
  fields = parselist(fieldname);
end

if length(fields)>1
  error('MATLAB:hdfgridread:tooManyFields', ...
        'Only one field at a time can be read from a Grid.');
end

if rem(length(varargin),2)
  error('MATLAB:hdfgridread:wrongParamValCount', ...
        'The parameter/value inputs must always occur as pairs.');
end

%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfgridread:invalidHinfoStruct',  ...
            'HINFO is not a valid structure describing HDF-EOS Grid data.  Consider using HDFINFO to obtain this structure.' );
    end
  end
else 
  error('MATLAB:hdfgridread:invalidHinfoStruct',  ...
        'HINFO is not a valid structure describing HDF-EOS Grid data.  Consider using HDFINFO to obtain this structure.' );
end

%Check to see if methods are exclusive.
exclusiveMethods = {'Index','Tile','Pixels','Interpolate'};
numPairs = length(varargin)/2;
params = varargin(1:2:end);

for i=1:numPairs
  match = strmatch(params{i},exclusiveMethods);
  if ~isempty(match) && numPairs>1
    error('MATLAB:hdfgridread:badSubsetParams', ...
          'Multiple exclusive subsetting parameters used.');
  end
end


%=================================================================
function [start,stride,edge] = defaultIndexSubset(Dims,startIn,strideIn,edgeIn)
%Calculate default start, stride and edge values if not defined in input
%START, STRIDE, and EDGE are one based

if any([startIn<1, strideIn<1, edgeIn<1])
  error('MATLAB:hdfgridread:badSubsetIndex', ...
        'START, STRIDE, and EDGE values must not be less than 1.');
end

rank = length(Dims);
if isempty(startIn) 
  start = zeros(1,rank);
else
  start = startIn-1;
end
if isempty(strideIn)
  stride= ones(1,rank);
else
  stride = strideIn;
end
if isempty(edgeIn)
  edge = zeros(1,rank);
  for i=1:rank
    edge(i) = fix((Dims(i).Size-start(i))/stride(i));
  end
else
  edge = edgeIn;
end





%=================================================================
function regionID = get_grid_regionid_from_time_period (fileID,gridID,regionID,params,values)

if iscell(values)
    if length(values)==2
        [start, stop] = deal(values{:});
    else
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
    end    
else
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:wrongNumberOfValues', '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
end

if isempty(regionID)
    regionID = hdfgd('deftimeperiod',gridID,-1,start,stop);
else
    regionID = hdfgd('deftimeperiod',gridID,regionID,start,stop);
end
if regionID == -1
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:defTimePeriodFailure', 'Generic failure of deftimeperiod' );
end


%=================================================================
function regionID = get_grid_regionid_from_box (fileID,gridID,params,values)

if iscell(values)
    if length(values)==2
        [lon,lat] = deal(values{:});
    else
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
    end
else
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:wrongNumberOfValues', ...
          '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
end
regionID = hdfgd('defboxregion',gridID,lon,lat);
if regionID == -1
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:hdfgdFailure', 'Generic failure of defboxregion' );
end




%=================================================================
function data = get_grid_data_from_interpolate (fileID,gridID,fieldname,params,values)
if iscell(values)
    if length(values)==2
        [lon,lat] = deal(values{:});
    else
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
    end
else
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:wrongNumberOfValues', ...
          '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
end

try
    [data, status] = hdfgd('interpolate',gridID,lon,lat,fieldname);
    if status == -1
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:interpolateFailure', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
    end
catch myException
    closeGDInterfaces(fileID,gridID);
    rethrow(myException);
end






%=================================================================
function data = get_grid_data_from_pixels (fileID,gridID,fieldname,params,values)

if iscell(values)
    if length(values)==2
        [lon,lat] = deal(values{:});
    else
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
    end
else
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:wrongNumberOfValues', ...
          '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
end

try
    [rows,cols,status] = hdfgd('getpixels',gridID,lon,lat);
    if status
        closeGDInterfaces(fileID,gridID);
        error ( 'MATLAB:hdfgridread:getpixels', 'Generic hdfgd failure stemming from getpixels' );
    end
    [data,status] = hdfgd('getpixvalues',gridID,rows,cols,fieldname);
    if status < 0
        closeGDInterfaces(fileID,gridID);
        error ( 'MATLAB:hdfgridread:getpixvalues', 'Generic hdfgd failure stemming from getpixvalues' );
    end
catch myException
    closeGDInterfaces(fileID,gridID);
    rethrow(myException);
end






%=================================================================
function regionID = get_grid_regionid_via_vertical(fileID,gridID,regionID,params,values)

if iscell(values)
    if length(values)==2
        [dimension,range] = deal(values{:});
    else
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
    end
else
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:wrongNumberOfValues', ...
          '''%s'' method requires %i value(s) to be stored in a cell array.', params, 2);
end


if isempty(regionID)
  regionID = hdfgd('defvrtregion',gridID,-1,dimension,range);
else
  regionID = hdfgd('defvrtregion',gridID,regionID,dimension,range);
end
if regionID == -1
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:hdfgdFailure', 'Generic failure of hdfgd stemming from defvrtregion' );
end





%=================================================================
function data = get_grid_data_via_tiles (fileID,gridID,fieldname,params,values)

if iscell(values)
    if length(values)==1
        tileCoords = values{:}-1;
    else
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', '''%s'' method requires %i value(s) to be stored in a cell array.', params, 1);
    end
else
    tileCoords = values-1;
end

[~,~,~,status] = hdfgd('tileinfo',gridID,fieldname);
if ( status == -1 )
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:noTiles', ...
        'The ''Tile'' parameter was specified, but ''%s'' is not defined on a tiled grid.', ...
        fieldname );
end

if any(tileCoords<1)
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:badTile', ...
            '''Tile'' values must not be less than 1.');
end

try
    [data,status] = hdfgd('readtile',gridID,fieldname,tileCoords);
    if status
        closeGDInterfaces(fileID,gridID);
        error ( 'MATLAB:hdfgridread:readtile', 'Generic hdfgd failure stemming from readtile' );
    end
catch myException
    closeGDInterfaces(fileID,gridID);
    rethrow(myException);
end







%=================================================================
function data = get_grid_data_via_index (hinfo,fileID,gridID,fieldname,params,values)

if iscell(values)
    if length(values)==3
        [start,stride,edge] = deal(values{:});
    else
        closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', params, 3);
    end
else
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:wrongNumberOfValues', ...
          '''%s'' method requires %i value(s) to be stored in a cell array.', params, 3);
end

for j=1:length(hinfo.DataFields)
    match = strmatch(fieldname,hinfo.DataFields(j).Name,'exact');
    if match
        break;
    end
end

if isempty(match)
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:fieldNotFound', ...
            '''%s'' field not found.  Data field may not exist.', ...
            fieldname);
else
    try
        [start,stride,edge] = defaultIndexSubset(hinfo.DataFields(j).Dims, ...
                                                 start, stride, edge);
    catch myException 
        closeGDInterfaces(fileID,gridID);
        rethrow(myException)
    end
      
    try
        [data,status] = hdfgd('readfield',gridID,fieldname,start,stride,edge);
        if status
            closeGDInterfaces(fileID,gridID);
            error ( 'MATLAB:hdfgridread:readfield', 'Generic hdfgd failure stemming from readfield' );
        end
    catch myException
        closeGDInterfaces(fileID,gridID);
        rethrow(myException);
    end
end

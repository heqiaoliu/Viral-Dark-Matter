function data = hdfswathread(hinfo,fieldname,varargin)
%HDFSWATHREAD
%  
%   DATA=HDFSWATHREAD(HINFO,FIELD) reads data from the field FIELD of an
%   HDF-EOS Swath structure identified by HINFO.  
%   
%   DATA=HDFSWATHREAD(HINFO,FIELD,PARAM,VALUE,PARAM2,VALUE2,...) reads
%   data from an HDF-EOS swath structure identified by HINFO.  The data is
%   subset with the parameters PARAM, PARAM2,... with the particular type of
%   subsetting defined in SUBSET.  
%   
%   SUBSET may be any of the strings below, defined in HDFINFO:
%   
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |   'ExtMode'
%   
%   The 'Fields' subsetting method is required. The SUBSET method 'Index' may 
%   not be used with any other method of subsetting the Swath data.  'Time' 
%   may be used alone, following 'Box', or following 'Vertical' subsetting.  
%   'Vertical may be used without previous subsetting, following 'Box' or 
%   'Time' subsetting.  When subsetting by time or region, 'ExtMode' can be
%   set to either 'Internal', geolocation fields and data fields must be
%   in the same swath, or 'External', geolocation fields and data fields may
%   be in different swaths.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/02/06 14:23:00 $

data = [];
regionID = [];

%Verify inputs are valid
parseInputs(hinfo,fieldname,varargin{:});

%Open interfaces
fileID = hdfsw('open',hinfo.Filename,'read');
if fileID==-1
  error('MATLAB:hdfswathread:interfaceOpen', ...
        'Unable to open Swath interface for ''%s'' data set. File may be corrupt.', hinfo.Filename);
end
swathID = hdfsw('attach',fileID,hinfo.Name);
if swathID==-1
  hdfsw('close',fileID);
  error('MATLAB:hdfswathread:interfaceAttach', ...
        'Unable to attach Swath interface for ''%s'' data set. File may be corrupt.', hinfo.Filename);
end

%Defaults
numPairs = length(varargin)/2;
if numPairs==0
  numPairs = 1;
  params = {'index'};
  values = {{[],[],[]}};
else
  params = varargin(1:2:end);
  values = varargin(2:2:end);
  extmodeidx = strmatch('extmode',lower(params));
  if extmodeidx
    extmode = lower(values{extmodeidx});
    params(extmodeidx) = [];
    values(extmodeidx) = [];
    numPairs = numPairs-1;
  else
    extmode = 'internal';
  end
end

%Just in case
params = lower(params);

%
% Check for consistency.  Do not allow both a geolocation restriction and 
% a dimension restriction if the dimension name is the same
validate_vertical_restriction ( fileID, swathID, params, values );

%Subset and read
for i=1:numPairs
    switch params{i}
        case 'index'
            data = hdfswathread_index(fileID,swathID,fieldname,hinfo,params{i},values{i});

        case 'box'
            regionID = hdfswathread_box(fileID,swathID,params{i},values{i});

        case 'time'
            data = hdfswathread_time(fileID,swathID,fieldname,params{i},values{i},extmode);

        case 'vertical'
            regionID = hdfswathread_vertical(fileID,swathID,regionID,params{i},values{i});

        otherwise
            closeSWInterfaces(fileID,swathID);
            error('MATLAB:hdfswathread:subsetMethod', ...
                'Unrecognized subsetting method: ''%s''.', params{i});
    end
end

if ~isempty(regionID) && regionID~=-1
    try
        [data,status] = hdfsw('extractregion',swathID,regionID,fieldname,extmode);
        if status == -1
            msg = hdferrmsg ( status );
            error ( 'MATLAB:hdfswathread:extractregion', msg );
        end
    catch myException
        closeSWInterfaces(fileID,swathID);
        error('MATLAB:hdfswathread:extractregion', myException.message);
    end
end

closeSWInterfaces(fileID,swathID);

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);


%=================================================================
function closeSWInterfaces(fileID,swathID)
%Close interfaces
try %#ok<TRYNC>
    hdfsw('detach',swathID);
end
try %#ok<TRYNC>
    hdfsw('close',fileID);
end


%=================================================================
function parseInputs(hinfo,fieldname,varargin)

if isempty(fieldname)
  error('MATLAB:hdfswathread:fieldsNotProvided', ...
        'Must use ''Fields'' parameter when reading HDF-EOS Swath data sets.');
else
  fields = parselist(fieldname);
end

if length(fields)>1
  error('MATLAB:hdfswathread:tooManyFields', ...
        'Only one field at a time can be read from a Swath.');
end


if rem(length(varargin),2)
  error('MATLAB:hdfswathread:paramValuePairs', ...
        'The parameter/value inputs must always occur as pairs.');
end

%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields','GeolocationFields'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfswathread:invalidHinfoStruct', ...
            'HINFO is not a valid structure describing HDF-EOS Swath data.' );
    end
  end
else 
  error('MATLAB:hdfswathread:invalidHinfoStruct', ...
        'HINFO is not a valid structure describing HDF-EOS Swath data.' );
end

%Check to see if methods are exclusive.
exclusiveMethods = {'Index'};
numPairs = length(varargin)/2;
params = varargin(1:2:end);
foundExclusive = 0;
for i=1:numPairs
  if foundExclusive==1
    error('MATLAB:hdfswathread:inconsistentParameters', ...
          'Multiple exclusive subsetting parameters used.');
  else
    match = strmatch(params{i},exclusiveMethods);
    if ~isempty(match) && numPairs>1
      error('MATLAB:hdfswathread:inconsistentParameters', ...
            'Multiple exclusive subsetting parameters used.');
    end
  end
end


%=================================================================
function [start,stride,edge] = defaultIndexSubset(Dims,startIn,strideIn,edgeIn)
%Calculate default start, stride and edge values if not defined in input

if any([startIn<1, strideIn<1, edgeIn<1])
  error('MATLAB:hdfswathread:badStartStrideEdge', ...
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
  edge = zeros(1, rank);
  for i=1:rank
    edge(i) = fix((Dims(i).Size - start(i)) / stride(i));
  end
else
  edge = edgeIn;
end



%===============================================================================
function data = hdfswathread_index(fileID,swathID,fieldname,hinfo,param,value)

if iscell(value)
    if length(value)==3
        [start,stride,edge] = deal(value{:});
    else
        closeSWInterfaces(fileID,swathID);
        error('MATLAB:hdfswathread:paramValues', ...
              '''%s'' method requires %i value(s) to be stored in a cell array.', param, 3);
    end
else
    closeSWInterfaces(fileID,swathID);
    error('MATLAB:hdfswathread:paramValues',  ...
          '''%s'' method requires %i value(s) to be stored in a cell array.', param, 3);
end
for j=1:length(hinfo.DataFields)
    match = strmatch(fieldname,hinfo.DataFields(j).Name,'exact');
    if ~isempty(match)
        try
            [start,stride,edge] = defaultIndexSubset(hinfo.DataFields(j).Dims, ...
                    start, stride, edge);
        catch myException
            closeSWInterfaces(fileID,swathID);
            rethrow(myException)
        end
        break;
    end
end
if isempty(match)
    for j=1:length(hinfo.GeolocationFields)
        match = strmatch(fieldname,hinfo.GeolocationFields(j).Name,'exact');
        if ~isempty(match)
            try
                [start,stride,edge] = defaultIndexSubset(hinfo.GeolocationFields(j).Dims,start,stride,edge);
            catch myException
                closeSWInterfaces(fileID,swathID);
                rethrow(myException)
            end
            break
        end
    end
end

if isempty(match)
    closeSWInterfaces(fileID,swathID);
    error('MATLAB:hdfswathread:fieldNotFound', '''%s'' field not found.', fieldname);
else
    try
        [data,status] = hdfsw('readfield',swathID,fieldname,start,stride,edge);
        if status == -1
            closeSWInterfaces(fileID,swathID);
            msg = hdferrmsg ( status );
            error ( 'MATLAB:hdfswathread:readfield', msg );
        end
    catch myException
        closeSWInterfaces(fileID,swathID);
        error('MATLAB:hdfswathread:readfield', myException.message);
    end
end




%===============================================================================
function regionID = hdfswathread_box(fileID,swathID,param,value)

if iscell(value)
    if length(value)==3
        [lon, lat, mode] = deal(value{:});
    else
        closeSWInterfaces(fileID,swathID);
        error('MATLAB:hdfswathread:paramValues', ...
		      '''%s'' method requires %i value(s) to be stored in a cell array.', param, 3);
    end
else
    closeSWInterfaces(fileID,swathID);
    error('MATLAB:hdfswathread:paramValues', ...
	      '''%s'' method requires %i value(s) to be stored in a cell array.', param, 3);
end
try
    regionID = hdfsw('defboxregion',swathID,lon,lat,mode);
    if regionID == -1
        closeSWInterfaces(fileID,swathID);
        msg = hdferrmsg ( regionID );
        error ( 'MATLAB:hdfswathread:defboxregion', msg );
    end
catch myException
    closeSWInterfaces(fileID,swathID);
    error('MATLAB:hdfswathread:defboxregion', myException.message);
end


%===============================================================================
function data = hdfswathread_time(fileID,swathID,fieldname,param,value,extmode)
if iscell(value)
    if length(value)==3
        [start,stop,mode] = deal(value{:});
    else
        closeSWInterfaces(fileID,swathID);
        error('MATLAB:hdfswathread:paramValues', ...
		      '''%s'' method requires %i value(s) to be stored in a cell array.', param, 3);
    end
else
    closeSWInterfaces(fileID,swathID);
end

try
    periodID = hdfsw('deftimeperiod',swathID,start,stop,mode);
    if periodID == -1
        closeSWInterfaces(fileID,swathID);
        msg = hdferrmsg ( periodID );
        error ( 'MATLAB:hdfswathread:deftimeperiod', msg );
    end
    [data,status] = hdfsw('extractperiod',swathID,periodID,fieldname,extmode);
    if status == -1
        closeSWInterfaces(fileID,swathID);
        msg = hdferrmsg ( status );
        error ( 'MATLAB:hdfswathread:extractperiod', msg );
    end
catch myException
    closeSWInterfaces(fileID,swathID);
    error('MATLAB:hdfswathread:extractperiod', myException.message);
end


%===============================================================================
function regionID = hdfswathread_vertical(fileID,swathID,regionID,param,value)
if iscell(value)
    if length(value)==2
        [dimension,range] = deal(value{:});
    else
        closeSWInterfaces(fileID,swathID);
        error('MATLAB:hdfswathread:paramValues', ...
		      '''%s'' method requires %i value(s) to be stored in a cell array.', param, 3);
    end
else
    closeSWInterfaces(fileID,swathID);
    error('MATLAB:hdfswathread:paramValues', ...
	      '''%s'' method requires %i value(s) to be stored in a cell array.', param, 3);
end
if isempty(regionID)
    regionID = hdfsw('defvrtregion',swathID,'NOPREVSUB',dimension,range);
else
    regionID = hdfsw('defvrtregion',swathID,regionID,dimension,range);
end

%===============================================================================
function validate_vertical_restriction ( fileID, swathID, params, values )
% Check that we do not restrict on both a dimension and a geolocation variable
% of the same name.  Restricting on both does not really make sense, and the 
% HDF Swath interface will give inconsistent results in that case.

%
% If we have a dimension restriction and a geolocation restriction of the same 
% name, say 'DIM:Band_1KM_RefSB' and 'Band_1KM_RefSB', then we know we have
% a conflict.
geolocation_restriction_list = {};
dimension_restriction_list = {};
for i=1:numel(params)
    if ~strcmp(params{i},'vertical')
        continue
    end
    
    subset_obj = values{i}{1};
    
    if strcmp(subset_obj(1:4),'DIM:') && (numel(subset_obj) > 4)
        %
        % The subset object is a dimension.  Add it to the list.
        dimension_restriction_list{end+1} = subset_obj(5:end); %#ok<AGROW>
    else
        geolocation_restriction_list{end+1} = subset_obj; %#ok<AGROW>
    end
        
end


C = intersect(geolocation_restriction_list, dimension_restriction_list);
if ( numel(C) > 0 )
    closeSWInterfaces(fileID,swathID);
    error ( 'MATLAB:hdfswathread:incompatibleVerticalSubset', ...
            'Cannot perform a vertical subset with both ''DIM:%s'' and ''%s'' at the same time.', C{1}, C{1} );
        
end

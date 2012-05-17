function data = hdfvdataread(hinfo,fields,numrecords,firstRecord)
%HDFVDATAREAD read HDF Vdata
%   
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data vdata set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO.
%   
%   DATA = HDFREAD(HINFO,FIELDS) reads all data from the comma separated
%   list of FIELDS in a Vdata set.
%   
%   DATA = HDFREAD(HINFO,FIELDS,NUMRECORDS) reads NUMRECORDS from the comma
%   separated list of FIELDS in a Vdata set.
%   
%   DATA = HDFREAD(HINFO,FIELDS,NUMRECORDS,FIRSTRECORD) reads NUMRECORDS
%   starting at record FIRSTRECORD from the comma separated list of FIELDS
%   in a Vdata set.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/14 17:24:00 $


error(nargchk(1,4,nargin, 'struct'));

[fields,numrecords,firstRecord] = parseVdataInputs(hinfo,fields, numrecords,firstRecord);

%Start interfaces
fileID = hdfh('open',hinfo.Filename,'read',0);
if fileID == -1
  error('MATLAB:hdfvdataread:interfaceOpen', ...
        'Problem opening Vdata set ''%s''. The dataset may not exist or the file may be corrupt.',hinfo.Name);
end
status = hdfv('start',fileID);
if status == -1
  hdfh('close',fileID);
  error('MATLAB:hdfvdataread:interfaceStart', ...
        'Problem opening Vdata set ''%s''. The dataset may not exist or the file may be corrupt.',hinfo.Name);
end

%Attach to data set
vdID = hdfvs('attach',fileID,hinfo.Ref,'r');
if vdID == -1
  close_vh_interfaces(vdID,fileID);
  error('MATLAB:hdfvdataread:interfaceAttach', ...
        'Problem reading Vdata set ''%s''. The dataset may not exist or the file may be corrupt.',hinfo.Name) ;
end

status = hdfvs('setfields',vdID,fields);
if status == -1
    close_vh_interfaces(vdID,fileID);
    msg = hdferrmsg ( status );
    error ( 'MATLAB:hdfvdataread:setFieldsFailed', msg );
end

if firstRecord~=0
  pos = hdfvs('seek',vdID,firstRecord);
  if pos == -1
      close_vh_interfaces(vdID,fileID);
      msg = hdferrmsg ( pos );
      error ( 'MATLAB:hdfvdataread:seekFailed', msg );
  end
end

[data,count] = hdfvs('read',vdID,numrecords);
if count == -1
    close_vh_interfaces(vdID,fileID);
    msg = hdferrmsg ( count );
    error ( 'MATLAB:hdfvdataread:readFailed', msg );
end

close_vh_interfaces(vdID,fileID);


%============================================================
function [fields,numrecords,firstRecord] = parseVdataInputs(hinfo,fields,numrecords,firstRecord)
	  
%Validate fields of hinfo structure
if ~isstruct(hinfo)
  error('MATLAB:hdfvdataread:invalidHinfoStruct', ...
        'Invalid input arguments.  HINFO is not a valid structure describing a Vdata set.  Consider using HDFINFO to obtain this structure.' );
end
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Fields','Ref','NumRecords'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfvdataread:invalidHinfoFields', ...
	        'Invalid input arguments.  HINFO is not a valid structure describing a Vdata set.  Consider using HDFINFO to obtain this structure.' );
    end
  end
else 
  error('MATLAB:hdfvdataread:tooFewHinfoFields', ...
        'Invalid input arguments.  HINFO is not a valid structure describing a Vdata set.  Consider using HDFINFO to obtain this structure.' );
end
if ~isfield(hinfo.Fields,'Name')
  error('MATLAB:hdfvdataread:missingHinfoName', ...
        'Invalid input arguments.  HINFO is not a valid structure describing a Vdata set.  Consider using HDFINFO to obtain this structure.' );
end

%Assign default values to parameters not defined in input
if isempty(fields)
  fields = sprintf('%s,',hinfo.Fields.Name);
  fields(end) = [];
end

if isempty(firstRecord)
  firstRecord = 0;
elseif firstRecord>=1
    firstRecord = firstRecord-1;
else
  error('MATLAB:hdfvdataread:badFirstRecord', ...
        'FirstRecord must be 1 or greater.');
end

if isempty(numrecords)
  numrecords = hinfo.NumRecords - firstRecord;
end

if numrecords<=0
  error('MATLAB:hdfvdataread:badNumberOfRecords', ...
        'Number of records to read must be 1 or greater.  Check that \nFirstRecord does not exceed the total number of records in the Vdata.');
end




%=================================================================
function close_vh_interfaces(vdID,fileID)
%Close interfaces
try %#ok<TRYNC>
	hdfvs('detach',vdID);
end
try %#ok<TRYNC>
  hdfv('end',fileID);
end
try %#ok<TRYNC>
  hdfh('close',fileID);
end

function [data,map] = hdfraster8read(hinfo)
%HDFRASTER8READ
%
%   [DATA,MAP] = HDFRASTER8READ(HINFO) returns in the variable DATA the
%   image from the file for the particular 8-bit raster image described by
%   HINFO.  MAP contains the colormap if one exists for the image.  HINFO is
%   A structure extracted from the output structure of HDFINFO.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/07/31 20:04:19 $

parseInputs(hinfo);

status = hdfdfr8('readref',hinfo.Filename,hinfo.Ref);
if status == -1
	msg = hdferrmsg(status);
	error ( 'MATLAB:hdfraster8read:readref', msg );
end

[data,map,status]  = hdfdfr8('getimage',hinfo.Filename);
if status == -1
	msg = hdferrmsg(status);
	error ( 'MATLAB:hdfraster8read:getimage', msg );
end

status = hdfdfr8('restart');
if status == -1
	msg = hdferrmsg(status);
	error ( 'MATLAB:hdfraster8read:restart', msg );
end

%Put the image data and colormap in the right order for image display in
%MATLAB
data = data';
map = double(map')/255;
return;

%=======================================================================
function parseInputs(hinfo)

error(nargchk(1,1,nargin, 'struct'));

%Verify required fields

if ~isstruct(hinfo)
  error('MATLAB:hdfraster8read:invalidInputs', ...
        'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.' );
end
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Ref'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfraster8read:invalidInputs', ...
	        'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.' );
    end
  end
else 
  error('MATLAB:hdfraster8read:invalidInputs', ...
        'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.' );
end
return;






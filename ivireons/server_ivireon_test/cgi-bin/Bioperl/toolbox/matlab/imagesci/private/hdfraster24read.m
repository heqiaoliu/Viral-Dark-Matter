function data = hdfraster24read(hinfo)
%HDFRASTER24READ
%
%   DATA = HDFRASTER24READ(HINFO) returns in the variable DATA the image
%   from the file for the particular 24-bit raster image described by HINFO.
%   HINFO is a structure extracted from the output structure of HDFINFO.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/07/31 20:04:18 $

parseInputs(hinfo);
status = hdfdf24('readref',hinfo.Filename,hinfo.Ref);
if status == -1
  	msg = hdferrmsg(status);
  	error ( 'MATLAB:hdfraster24:readref', msg );
end
	
[data, status] = hdfdf24('getimage',hinfo.Filename);
if status == -1
  	msg = hdferrmsg(status);
  	error ( 'MATLAB:hdfraster24:getimage', msg );
end
	
status = hdfdf24('restart');
if status == -1
  	msg = hdferrmsg(status);
  	error ( 'MATLAB:hdfraster24:restart', msg );
end

%Put the image data in the right order for image display in MATLAB
data = permute(data,[3 2 1]);
return;

%=======================================================================
function parseInputs(hinfo)

error(nargchk(1,1,nargin, 'struct'));
	  
%Verify required fields

if ~isstruct(hinfo)
    error('MATLAB:hdfraster24read:invalidInputs', ...
	      'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.' );
end
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Ref'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfraster24read:invalidInputs', ...
	        'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.' );
    end
  end
else 
  error('MATLAB:hdfraster24read:invalidInputs', ...
        'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.' );
end

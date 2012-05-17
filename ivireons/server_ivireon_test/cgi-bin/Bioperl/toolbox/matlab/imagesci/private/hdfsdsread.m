function data  = hdfsdsread(hinfo,start,stride,edge)
%HDFSDSREAD read HDF Scientific Data Set
%
%   DATA = HDFSDSREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is A
%   structure extracted from the output structure of HDFINFO.
%   
%   DATA = HDFSDSREAD(HINFO,START,STRIDE,EDGE) reads data from a Scientific
%   Data Set.  START specifies the location in the data set to begin
%   reading. Each number in START must be smaller than its corresponding
%   dimension.  STRIDE is an array specifying the interval between the
%   values to be read.  EDGE is an array specifying the length of each
%   dimension to be read.  The sum of EDGE and START must not exceed the
%   size of the corresponding dimension.  The START, STRIDE and EDGE arrays
%   must be arrays the same size as the number of dimensions.  If START, 
%   STRIDE, or EDGE is empty then the default values are used.  START,
%   STRIDE and EDGE are one based.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/03/09 19:22:21 $


%Parse inputs and assign default parameters
[start,stride,edge] = parseSDSInputs(hinfo,start,stride,edge);

sdID = hdfsd('start',hinfo.Filename,'read');
if sdID == -1
  error('MATLAB:hdfsdsread:sdsStart', ...
        'Problem opening file %s. The file may be corrupt.',hinfo.File);
end
sdsID = hdfsd('select',sdID,hinfo.Index);
if sdsID == -1
  hdfsd('end',sdID);
  error('MATLAB:hdfsdsread:sdsSelect', ...
        'Problem selecting Scientific Data Set ''%s''. The data set may not exist or file may be corrupt.',hinfo.Name) ;
end

%  HDFSD('readdata',... will error with incorrect input arguments.  To prevent
%  leaving open identifiers if an error occurs, catch the error then and return
%  a warning.
try
  [data,status] = hdfsd('readdata',sdsID,start,stride,edge);
catch myException
  hdfsd('endaccess',sdsID);
  hdfsd('end',sdID);
  error('MATLAB:hdfsdsread:sdsReaddata', myException.message);
end
if status == -1
  hdfsd('endaccess',sdsID);
  hdfsd('end',sdID);
  error('MATLAB:hdfsdsread:sdsReaddata', ...
        'Problem reading Scientific Data Set ''%s''.  The file may be corrupt or the indexing may be incorrect.',hinfo.Name);
end


%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);

status = hdfsd('endaccess',sdsID);
if status == -1
    hdfsd('end',sdID);
    error('MATLAB:hdfsdsread:sdsEndAccess', 'Could not close dataset %s.', hinfo.Name);
end
status = hdfsd('end',sdID);
if status == -1
    error('MATLAB:hdfsdsread:sdsEnd', 'Could not close file %s.', hinfo.Filename);
end
return;

%============================================================
function [start,stride,edge] = parseSDSInputs(hinfo,start,stride,edge)
%Check for valid inputs to HDFSDSREAD
%There must be START, STRIDE, and EDGE parameters
error(nargchk(1,4,nargin, 'struct'));

%Assign default values to parameters not defined in input
%start, stride and edge are one based. 
if any([start<1, stride<1, edge<1])
  error('MATLAB:hdfsdsread:invalidStartStrideEdge', ...
        'START, STRIDE, and EDGE values must be 1 or greater.');
end

if isempty(start)
  start = zeros(1,hinfo.Rank);
else
  start = start-1;
end

if isempty(stride)
  stride = ones(1,hinfo.Rank);
end

if isempty(edge)
  for i=1:hinfo.Rank
    edge(i) = fix((hinfo.Dims(i).Size-start(i))/stride(i));
  end
end

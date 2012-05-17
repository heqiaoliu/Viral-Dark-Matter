function Slice = getSlice(this,Section,CellOutputFlag)
%GETSLICE  Extracts time slice from timeseries storage array.
%
%   Array = GETSLICE(ValueArray,Section)
%
%   Array = GETSLICE(ValueArray,Section,'cell')

%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:54:23 $

% Attempt to use the datasrc getSlice method first
try
    % If there is no samplesize (i.e. this is the first time a data src has
	% been accessed) try to call the "getDims" method to find the number of
	% datasrc dimensions. 
	if isempty(this.SampleSize)
		try 
           is = repmat({':'},1,this.Storage.getDims);
		catch
           is = repmat({':'},1,2);
		end
	end
    % Extract slice
    A = this.Storage.getSlice([Section is],this.Variable);
    
    % If time is stored as absolute dates on the datasrc
    if strcmp(this.Variable.Name,'Time') && iscell(A)
        A = localParseTime(this, A);
    end
    localSetSampleSize(this,A); % Set samplesize
catch % Otherwise get all the time vec and slice it here
    A = this.Storage.getArray(this.Variable);
    
    if strcmp(this.Variable.Name,'Time') && iscell(A)
        A = localParseTime(this, A);
    end
    localSetSampleSize(this,A);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Begin code copied from parent @ValueArray/getSlice

	% Get full array
	if ~isempty(A)
       % Expand grid dimensions
       SampleSize = this.SampleSize;
       SizeA = hdsGetSize(A);
       if length(Section)==1
          % Absolute indexing: collapse grid dimensions
          A = this.utReshape(A,[prod(SizeA)/prod(SampleSize) 1]);
       end
       
       % Extract slice, taking sample size into account
       is = repmat({':'},[1 length(SampleSize)]);
       if this.GridFirst
          A = hdsGetSlice(A,[Section is]);
       else
          A = hdsGetSlice(A,[is Section]);
       end
       
	end
end

% Format output
if nargin<3 || ~strcmp(CellOutputFlag,'cell')
   Slice = A;
elseif isa(A,'cell') && prod(SampleSize)==1
   % Cell array with one sample per cell
   Slice = A;
else
   % Convert to cell array with one data point per cell
   Slice = this.utArray2Cell(A);
end



function data = localParseTime(h, Slice)

% If the time vector is returned as a cell array, the data source is 
% specifying an absolute time vector. Consequently we must translate back
% into relative terms before passign data back. Subtract the reference and 
% express the data in the correct units

data = datenum(Slice);
if ~isempty(h.Metadata.Startdate)
   data = data-datenum(h.Metadata.Startdate);
end
data = tsunitconv(h.Metadata.Units,'days')*data;


function localSetSampleSize(h,A)

% Set the sample size
s = size(A);
if length(s)>=2
    h.SampleSize = [s(2) 1];
else
    h.SampleSize = s(2:end);
end
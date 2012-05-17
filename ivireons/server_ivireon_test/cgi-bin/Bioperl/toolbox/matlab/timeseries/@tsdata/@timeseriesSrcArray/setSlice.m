function setSlice(this,Section,B,GridSize)
%SETSLICE  Extracts  slice from time series data storage
%
%   SETSLICE(ValueArray,Section,Array,GridSize)

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/20 22:59:28 $

% RE: Assumes B is a subarray of A
Ns = prod(GridSize);

% Try to slice into the data source. If this is not supported by the 
% data source then extract all the data and slice it here

% Many data sinks may store time vectors as datestrs. To support being
% able to write times in this form, if the @timemetadata format is a
% datestr, the variable is "time" and the time vecotor is defined in an
% absolute sense then the time vecotr will be written to the data src
% as an array of datestrs
if strcmp(this.Variable.Name,'Time') && strcmp(this.Metadata.Format,'datestr') && ...
    ~isempty(this.Metadata.Startdate)
    B = cellstr(datestr(B*tsunitconv('days',this.Metadata.Units)+ ...
        datenum(this.Metadata.Startdate)));
end
    
try 
    % Data Src set slice method
    this.Storage.setSlice(Section,this.utReshape(B,[NsB 1]));
catch 
    GridSizeB = cellfun('length',Section);
	NsB = prod(GridSizeB);
	
	A = this.MetaData.getData(this.Data);
	
	% Align formats of A and B (cell array of samples vs. compound array
	% aggregating grid and sample dimensions for evenly sized samples)
	if isempty(A)
       % Creating new array
	
       if isempty(B)
          return
       end
       % Create new array of size grid size and data type inherited from SLICE
       if this.GridFirst
          A = zeros([GridSize this.SampleSize]);
       else
          A = zeros([this.SampleSize GridSize]);
       end
	end
	
	
	% Always Absolute indexing for time series
	A = this.utReshape(A,[Ns 1]);
	B = this.utReshape(B,[NsB 1]);
     
	is = repmat({':'},[1 length(SampleSize)]);
	if this.GridFirst
       A = hdsSetSlice(A,[Section is],B);
	else
       A = hdsSetSlice(A,[is Section],B);
	end
	
	% Always Absolute indexing for time series
	A = this.utReshape(A,GridSize);
	
	
	this.setArray(this.MetaData.setData(A));
end




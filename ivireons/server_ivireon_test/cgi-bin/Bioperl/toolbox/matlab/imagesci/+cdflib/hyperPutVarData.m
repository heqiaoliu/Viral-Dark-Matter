function hyperPutVarData(cdfId,varNum,recSpec,dimSpec,data)
%cdflib.hyperPutVarData Write variable hyperslab
%   cdflib.hyperPutVarData(cdfId,varNum,recSpec,dimSpec,data) writes a 
%   hyperslab of data to the variable specified by varNum in the CDF
%   identified by cdfId.  The hyperslab is described by the record 
%   specification recSpec and the dimension specification dimSpec.  recSpec 
%   is a three-element array described by [RSTART RCOUNT RSTRIDE], where 
%   RSTART, RCOUNT, and RSTRIDE are scalar values giving the start, number 
%   of records, and sampling interval or stride between records.  dimSpec 
%   is a three-element cell array described by {DSTART DCOUNT DSTRIDE}, 
%   where DSTART, DCOUNT, and DSTRIDE are n-element vectors that describe 
%   the start, number of values along each dimension, and sampling interval 
%   along each dimension.
%
%   All record numbers and dimension indices are zero-based numbers.
%
%   This function corresponds to the CDF library C API routine 
%   CDFhyperzPutVarData.  
%
%   Example:  Rewrite the first element in each of the first six records of
%   the 'Temperature' variable.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       recspec = [0 6 1];
%       dimspec = {[0 0],[1 1],[1 1]};
%       newdata = int16([5:-1:0]);
%       cdflib.hyperPutVarData(cdfid,varnum,recspec,dimspec,newdata);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.hyperGetVarData.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:41:25 $

error ( nargchk(5,5,nargin,'struct') );

if (~isa(recSpec,'double') || (numel(recSpec) ~= 3) )
	error('MATLAB:cdflib:hyperPutVarData:badRecSpecDatatype', ...
	    'The record specification must be a three-element double precision vector.' );
end
recstart = recSpec(1);
reccount = recSpec(2);
recstride = recSpec(3);

if ( ~isa(dimSpec,'cell') || (numel(dimSpec) ~= 3) )
	error('MATLAB:cdflib:hyperPutVarData:badDimSpecDatatype', ...
	    'The dimension specification must be a three-element cell array.' );
end
dstart = dimSpec{1};
dcount = dimSpec{2};
dstride = dimSpec{3};
if ~isa(dstart,'double') || ~isa(dcount,'double') || ~isa(dstride,'double')
	error('MATLAB:cdflib:hyperPutVarData:badRecSpecDatumDatatype', ...
	    'The elements of the dimension specification must be double precision arrays.');
end
if (numel(dstart) ~= numel(dcount)) || (numel(dstart) ~= numel(dstride))
	error('MATLAB:cdflib:hyperPutVarData:badRecSpecDatumDatatype', ...
	    'The length of each element of the dimension specification must be the same.');
end

cdflibmex('hyperPutVarData',cdfId,varNum, ...
	recstart, reccount, recstride, ...
	dstart, dcount, dstride, ...
	data);


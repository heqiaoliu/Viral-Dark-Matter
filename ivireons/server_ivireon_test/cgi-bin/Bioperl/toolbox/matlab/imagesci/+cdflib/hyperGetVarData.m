function data = hyperGetVarData(cdfId,varNum,recSpec,dimSpec)
%cdflib.hyperGetVarData Read hyperslab
%   data = cdflib.hyperGetVarData(cdfId,varNum,recSpec,dimSpec) reads a 
%   hyperslab of data from the variable specified by varNum in the CDF
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
%   data = cdflib.hyperGetVarData(cdfId,varNum,recSpec) reads a hyperslab
%   of data for a zero-dimensional variable.
%
%   All record numbers and dimension indices are zero-based numbers.
%
%   This function corresponds to the CDF library C API routine 
%   CDFhyperGetzVarData.  
%
%   Example:  Retrieve the first element in the first six records of the
%   'Temperature' variable.
%       cdfid = cdflib.open('example.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       recspec = [0 6 1];
%       dimspec = {[0 0], [1 1], [1 1]};
%       data = cdflib.hyperGetVarData(cdfid,varnum,recspec,dimspec);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.hyperPutVarData.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/05/13 17:41:24 $


if (~isa(recSpec,'double') || (numel(recSpec) ~= 3) )
    error('MATLAB:cdflib:hyperGetVarData:badRecSpecDatatype', ...
        'The record specification must be a three-element double precision vector.' );
end
recstart = recSpec(1);
reccount = recSpec(2);
recstride = recSpec(3);

info = cdflib.inquireVar(cdfId,varNum);

if nargin == 4
    if ( ~isa(dimSpec,'cell') || (numel(dimSpec) ~= 3) )
        error('MATLAB:cdflib:hyperGetVarData:badDimSpecDatatype', ...
            'The dimension specification must be a three-element cell array.' );
    end

    dstart = dimSpec{1};
    dcount = dimSpec{2};
    dstride = dimSpec{3};
    if ~isa(dstart,'double') || ~isa(dcount,'double') || ~isa(dstride,'double')
        error('MATLAB:cdflib:hyperGetVarData:badRecSpecDatumDatatype', ...
            'The elements of the dimension specification must be double precision arrays.');
    end
    if (numel(dstart) ~= numel(dcount)) || (numel(dstart) ~= numel(dstride))
        error('MATLAB:cdflib:hyperGetVarData:badRecordSpecLengths', ...
            'The length of each element of the dimension specification must be the same.');
    end

    if isempty(info.dimVariance)
        error('MATLAB:cdflib:hyperGetVarData:unwantedDimSpec', ...
            '''%s'' has no dimensions.  The dimension specification must be omitted when the number of dimensions is zero.', ...
            info.name  );
    end


else
    if ( ~isempty(info.dims) )
        error('MATLAB:cdflib:hyperGetVarData:missingDimensionSpecification', ...
            '''%s'' has %d dimensions.  The dimension specification cannot be omitted when the number of dimensions is not zero.', ...
            info.name, numel(info.dims) );
    end
    dstart = [];
    dcount = [];
    dstride = [];
end

data = cdflibmex('hyperGetVarData',cdfId,varNum, ...
    recstart, reccount, recstride, ...
    dstart, dcount, dstride );


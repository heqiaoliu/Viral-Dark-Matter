function this = migrateistimefirst(this)
%MIGRATEISTIMEFIRST Temporary method to fix timeseries isTimeFirst property
%to conform with behavior in future releases. This method will be removed
%in a future release.
%
%   This operation modifies a timeseries object where the value of the
%   isTimeFirst property will not be permitted in future releases. The
%   method may permute the contents of the DATA property of the timeseries.
%

%   Copyright 2009-2010 The MathWorks, Inc.

if numel(this)~=1
    error('timeseries:migrateistimefirst:noarray',...
        'The migrateistimefirst method can only be used for a single timeseries object');
end

% Check that the isTimeFirst property of this timeseries will be different
% in 10b. If not, quick return.
len = this.Length;
if ~isempty(this.Storage_) || this.DataInfo.isstorage
    if ~isempty(this.Storage_) 
        sData = this.Storage_.getSize(input,this.TimeInfo);
    else
        sData = this.DataInfo.getSize(input,this.TimeInfo);
    end
else
    sData = size(this.Data);
end
if len==0 || this.isTimeFirst == tsdata.datametadata.isTimeFirst(sData,...
        len,this.DataInfo.interpretSingleRowDataAs3D)
    return
end
data = this.Data;

% If the timeseries is a single row sample, toggling the
% interpretSingleRowDataAs3D is enough to ensure that the isTimeFirst
% property will not change in 10b.
if len==1 && isvector(data) && size(data,1)==1
    this.DataInfo.interpretSingleRowDataAs3D = ~this.DataInfo.interpretSingleRowDataAs3D;
    return
end


% If the timeseries is not a single row, the data must be permuted so that
% the time dimension is moved to the start or end and the isTimeFirst
% property toggled accordingly.
n = ndims(this.data);
if this.IsTimeFirst
    this = init(this, permute(this.data,[2:n 1]), this.Time, ...
        permute(this.Quality,[2:n 1]), 'IsTimeFirst',~this.IsTimeFirst);
else
    this = init(this, permute(this.data,[n 1:n-1]), this.Time,...
        permute(this.Quality,[n 1:n-1]), 'IsTimeFirst',~this.IsTimeFirst);
end

function Value = get(tsc,varargin)
%GET  Access/Query time series property values.
%
%   VALUE = GET(TSC,'PropertyName') returns the value of the 
%   specified property of TSC.  An equivalent syntax is 
%
%       VALUE = TSC.PropertyName 
%   
%   GET(TSC) displays all properties of TSC and their values.  
%
%   See also TSCOLLECTION\SET

%   Copyright 2004-2006 The MathWorks, Inc.

error(nargchk(1,2,nargin));
if nargin==1
    Value = uttsget(tsc,varargin{:});
    tsNames = gettimeseriesnames(tsc);
    for k=1:length(tsNames)
        Value.(tsNames{k}) = getts(tsc,tsNames{k});
    end
else
    I = strcmpi(varargin{1},{'time','timeInfo','name','length'});
    if any(I)
        I = find(I);
        Value = tsc.(varargin{1});
    else
        Value = getts(tsc,varargin{1});
    end
end
    
   

   
   

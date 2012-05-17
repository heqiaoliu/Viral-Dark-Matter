function [out coeffnames variables] = base_mapcoeffstoports(this,varargin)
%BASE_MAPCOEFFSTOPORTS 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 06:59:46 $

coeffnames = [];
variables = [];
[out idx] = parse_mapcoeffstoports(this,varargin{:});

if ~isempty(idx), 
    error(generatemsgid('InvalidParameter'), ...
        'The MapCoeffsToPorts parameter is not supported for %s filters.',class(this));
end

% [EOF]

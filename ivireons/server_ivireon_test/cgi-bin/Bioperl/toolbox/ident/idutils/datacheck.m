function [data, errstruct] = datacheck(data, ny, nu,command)
%DATACHECK: check consistency of data with ny and nu.
%
%  [data, errstruct] = datacheck(data, ny, nu)
%
% data is either an iddata object or a matrix.
% convert data to iddata object if it is a matrix.
% errstruct returns error struct.
%
% In case of multi-experiment iddata object, check also if the experiments
% all have the same sample time.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:21:27 $

% Author(s): Qinghua Zhang

errstruct = struct([]);
if ~isa(data, 'iddata')
    if isempty(data) || ...
            ~(isnumeric(data) && isreal(data) && all(all(isfinite(data))) && ndims(data)==2)
        errstruct = struct('identifier','Ident:general:DataFormat',...
            'message','Data must be specified as an IDDATA object.');
        return
    end
    if (ny+nu)~=size(data,2)
        errstruct = struct('identifier','Ident:general:modelDataDimMismatch',...
            'message','The number of inputs and outputs of the model must match that of the data.');
        return
    end
    % Convert data matrix to IDDATA object
    data = iddata(data(:,1:ny), data(:,ny+(1:nu)));
else
    [nsamp, nyd, nud, nex] = size(data);
    if nyd~=ny || nud~=nu
        errstruct = struct('identifier','Ident:general:modelDataDimMismatch',...
            'message','The number of inputs and outputs of the model must match that of the data.');
        return
    end

    % Check Ts of multi-experiments
    if nex>1
        Ts = pvget(data, 'Ts');
        if ~isequal(Ts{:})
            errstruct = struct('identifier','Ident:iddata:multiExpDataTsMismatch2',...
                'message','All data experiments must have the same sampling interval.');
            return
        end
    end
end

% FILE END

function emsg = checkparams(spec,params)
%CHECKPARAMS Check that the parameter vector is valid.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:38 $

if isempty(params)
    emsg = 'PARAMS cannot be empty.';
elseif ~isvector(params) || ~isnumeric(params)
    emsg = 'PARAMS must be a numeric vector.';
elseif numel(params) ~= numel(spec.pnames)
    emsg = sprintf('PARAMS vector must have %d elements.',...
                   numel(spec.pnames));
elseif any(isnan(params))
    emsg = ''; % allow creating a null object
elseif isfield(spec,'checkparam') && ~isempty(spec.checkparam) ...
                                  && ~spec.checkparam(params)
    emsg = 'PARAMS contains invalid values.';
else
    emsg = '';
end

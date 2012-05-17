function out_rtp = modifyTunableParameters(in_rtp, varargin)
% rtp = MODIFYTUNABLEPARAMETERS(rtp, idx)
% Expands rtp to have idx sets of parameters
%
% rtp = MODIFYTUNABLEPARAMETERS(rtp, parameterName, val, ...)
% Takes an rtp structure with tunable parameter information and sets the
% values associated with 'ParameterName' to be val if possible.  There can
% be more than one name value pair.
%
%
% If the mapping information is not there for 'ParameterName' or val has
% the wrong number of elements, rtp is returned unchanged and an error is
% issued.
%
% Copyright 2005-2008 The MathWorks, Inc.
% rtp = modifyTunableParameters(rtp, param, val, ....) with param val pairs
%

if nargin < 2
    % should error here instead
    help modifyTunableParameters;
    out_rtp = in_rtp;
    return;
end
out_rtp = sl('modifyRTP', in_rtp, varargin{:});

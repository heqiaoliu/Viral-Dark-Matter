function out_rtp = rsimsetrtpparam(in_rtp, varargin)
% rtp = RSIMSETRTPPARAM(rtp, idx)
% Expands rtp to have idx sets of parameters
%
% rtp = RSIMSETRTPPARAM(rtp, parameterName, val, ...)
% Takes an rtp structure with tunable parameter information and sets the
% values associated with 'ParameterName' to be val if possible.  There can
% be more than one name value pair.
%
% rtp = RSIMSETRTPPARAM(rtp, idx, parameterName, val, ...)
% Takes an rtp structure with tunable parameter information and sets the
% values associated with 'ParameterName' to be val in the idx'th parameter
% set.  There can be more than one name value pair.  If the rtp structure
% does not idx parameter sets, the first set is copied and appended until
% there are idx parameter sets then the idx'th set is changed
%
% The rtp structure should match the format of the structure return by 
% RSIMGETRTP(modelName)
%
% If the mapping information is not there for 'ParameterName' or val has
% the wrong number of elements, rtp is returned unchanged and an error is
% issued.
%
% see also: RSIMGETRTP

% Copyright 2005-2008 The MathWorks, Inc.

% syntax A
% rtp = rsimsetrtp(rtp, param, val, ....) with param val pairs
%
% syntax B
% rtp = rsimsetrtp(rtp, idx, param, val, ....) with param val pairs
%
% note it is possible to call with no param value pairs but with an idx to
% expand an rtp structure from one set to multiple sets

if nargin < 2
    % should error here instead
    help rsimsetrtpparam;
    out_rtp = in_rtp;
    return;
end
out_rtp = sl('modifyRTP', in_rtp, varargin{:});

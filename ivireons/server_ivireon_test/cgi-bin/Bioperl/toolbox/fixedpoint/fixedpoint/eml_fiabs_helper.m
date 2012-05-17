function [ntp_out, fmth_out, fimathSpecified, errMsg] = eml_fiabs_helper(A,varargin)

%   Copyright 2007-2009 The MathWorks, Inc.

errMsg = '';
% fmth_out = A.fimath;
% ntp_out = A.numerictype;
fimathSpecified = false;
ntp_out = [];
fmth_out = [];

if isempty(varargin)
    % abs(A)                                                                                                                                
    fmth_out = A.fimath;
    ntp_out = A.numerictype;

elseif (nargin == 2)&&(isnumerictype(varargin{1}))
    % abs(A,T)
    fmth_out = A.fimath;
    ntp_out = varargin{1};

elseif (nargin == 2)&&(isfimath(varargin{1}))
    % abs(A,F)
    fmth_out = varargin{1};
    fimathSpecified = true;
    ntp_out = A.numerictype;

elseif (nargin == 3)&&(isnumerictype(varargin{1}))&&(isfimath(varargin{2}))
    % abs(A,T,F)
    ntp_out = varargin{1};
    fmth_out = varargin{2};
    fimathSpecified = true;
    
elseif (nargin == 3)&&(isnumerictype(varargin{2}))&&(isfimath(varargin{1}))
    % abs(A,F,T)
    fmth_out = varargin{1};    
    ntp_out = varargin{2};
    fimathSpecified = true;
else
    errMsg = ...
           ['This syntax is not supported by the abs function. See the '...
           'Function reference page in the Fixed-Point Toolbox '...
           'documentation for a list of supported syntaxes.'];
       return;
            
end

if (isslopebiasscaled(A.numerictype) || isslopebiasscaled(ntp_out))
    errMsg = ...
     ['The abs function supports binary point-only scaling.'...
      'For any numerictype or fi object used with the abs '...
      'function, the fractional slope must be 1 and the bias must be zero.'];    
end

if isscaledtype(ntp_out) && isempty(ntp_out.SignednessBool)
    % If Signedness is Auto (e.g. unspecified), then set the output type to
    % Unsigned. 
    ntp_out.SignednessBool = false;
end

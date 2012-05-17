function q = quantizer(varargin)
%QUANTIZER Constructor for QUANTIZER object
%   Q = QUANTIZER creates a quantizer with all default values.
%   Q = QUANTIZER('Property1',Value1, 'Property2',Value2,...) assigns
%   values associated with named properties.
%
%   Refer to QUANTIZER for a detailed help
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2006/12/20 07:14:10 $


% Built-in UDD constructor
q = embedded.quantizer;

if nargin > 0
  setquantizer(q,varargin{:});
end

% Check out the Fixed-Point Toolbox License
persistent lmCheckedOut;
if isempty(lmCheckedOut)
    lmCheckedOut = false;
end
if ~lmCheckedOut
    license('checkout','fixed_point_toolbox');
    lmCheckedOut = true;
end


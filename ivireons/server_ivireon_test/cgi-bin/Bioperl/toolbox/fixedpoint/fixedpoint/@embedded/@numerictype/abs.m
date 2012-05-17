function Y = abs(A, varargin)
%ABS    Absolute value of built-in data-type with numerictype and (possibly) fimath
%
%   ABS(A,T) and ABS(A,T,F) return the absolute value of built-in argument 
%   A; Numerictype T and Fimath F (if specified) are ignored
%
%
%   See also EMBEDDED.FI/ABS, EMBEDDED.FIMATH/ABS, 
%            EMBEDDED.FI/COMPLEXABS, FI, EMBEDDED.FI/REALABS

%   Copyright 1999-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:54:00 $

error(nargchk(2, 3, nargin));
if (nargin == 3)&&(~isfimath(varargin{2}))
    error('fixedpoint:numerictype:abs:invalidOptionalIp',...
           ['This syntax is not supported by the abs function. See the '...
           'block reference page in the Fixed-Point Toolbox documentation'...
           ' for a list of supported syntaxes.']);
end
if (isnumerictype(A))
    error('fixedpoint:numerictype:abs:invalidIp',...
           ['This syntax is not supported by the abs function. See the '...
           'block reference page in the Fixed-Point Toolbox documentation'...
           ' for a list of supported syntaxes.']); 
end

Y = abs(A);


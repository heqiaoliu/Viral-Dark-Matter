function Y = abs(A, varargin)
%ABS    Absolute value of built-in data-type with fimath and (possibly) numerictype 
%
%   ABS(A,F) and ABS(A,F,T) return the absolute value of built-in argument
%   A; Fimath F and Numerictype T (if specified) are ignored
%
%
%   See also EMBEDDED.FI/ABS, EMBEDDED.NUMERICTYPE/ABS,
%            EMBEDDED.FI/COMPLEXABS, FI, EMBEDDED.FI/REALABS

%   Copyright 1999-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:53:55 $

error(nargchk(2, 3, nargin));
if (nargin == 3)&&(~isnumerictype(varargin{2}))
    error('fixedpoint:fimath:abs:invalidOptionalIp',...
           ['This syntax is not supported by the abs function. See the '...
           'block reference page in the Fixed-Point Toolbox documentation'...
           ' for a list of supported syntaxes.']); 
end
if (isfimath(A))
    error('fixedpoint:fimath:abs:invalidIp',...
           ['This syntax is not supported by the abs function. See the '...
           'block reference page in the Fixed-Point Toolbox documentation'...
           ' for a list of supported syntaxes.']); 
end

Y = abs(A);

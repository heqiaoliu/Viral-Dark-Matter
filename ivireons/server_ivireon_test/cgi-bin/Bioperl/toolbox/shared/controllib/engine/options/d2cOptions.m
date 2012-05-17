function obj = d2cOptions(varargin)
%D2COPTIONS  Creates option set for the D2C command.
%
%   OPT = D2COPTIONS returns the default options for D2C. The supported
%   options are:
%
%   Method                 Discretization method ('zoh','tustin', or
%                          'matched'). The default is 'zoh'.
%
%   PrewarpFrequency       Prewarp frequency in rad/s (for 'tustin'
%                          method only). The default value is zero which
%                          corresponds to the standard Tustin method.
%
%   See also D2C.

%   Author(s): Murad Abu-Khalaf , October 26, 2009
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $   $Date: 2010/02/08 22:52:28 $

try
    obj = initOptions(ltioptions.d2c,varargin);
catch E
    throw(E);
end
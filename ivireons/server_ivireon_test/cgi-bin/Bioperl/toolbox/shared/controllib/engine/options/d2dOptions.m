function obj = d2dOptions(varargin)
%D2DOPTIONS  Creates option set for the D2D command.
%
%   OPT = D2DOPTIONS returns the default options for D2D. The supported
%   options are:
%
%   Method               Discretization method ('zoh', or 'tustin').
%                        The default is 'zoh'.
%
%
%   PrewarpFrequency     Prewarp frequency in rad/s (for 'tustin' method 
%                        only). The default value is zero which corresponds 
%                        to the standard Tustin method.
%
%   See also D2D.

%   Author(s): Murad Abu-Khalaf , October 26, 2009
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $   $Date: 2010/02/08 22:52:29 $
try
   obj = initOptions(ltioptions.d2d,varargin);
catch E
   throw(E);
end
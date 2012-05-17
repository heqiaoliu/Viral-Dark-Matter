function obj = c2dOptions(varargin)
%C2DOPTIONS  Creates option set for the C2D command.
%
%   OPT = C2DOPTIONS returns the default options for C2D. The supported
%   options are:
%
%   Method                 Discretization method ('zoh','foh','impulse',
%                          'tustin', or 'matched'). The default is 'zoh'.
%
%   PrewarpFrequency       Prewarp frequency in rad/s (for 'tustin'
%                          method only). The default value is zero which
%                          corresponds to the standard Tustin method.
%
%   FractDelayApproxOrder  Order of the Thiran filters used to approximate 
%                          fractional delays in the 'tustin' and 'matched' 
%                          methods. For continuous-time delays TAU that are 
%                          not multiple of the sampling time TS, the 
%                          remainder of the division TAU/TS is called the 
%                          fractional delay. The default approximation order 
%                          is zero, meaning that fractional delays are
%                          rounded to the nearest integer. Nonzero orders
%                          result in better phase matching near the Nyquist
%                          frequency.
%
%   See also C2D.

%   Author(s): Murad Abu-Khalaf , August 5, 2009
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $   $Date: 2010/02/08 22:52:27 $

%================= The following property is undocumented ==================
%     FractDelayModeling     Determines how fractional delay filters
%                            are modeled. When set to 'delay', internal
%                            delays rather than extra states are used to
%                            augment the filters with the discretized
%                            system. Default is 'state'.
%==========================================================================

try
    obj = initOptions(ltioptions.c2d,varargin);
catch E
    throw(E);
end
function sys = d2d(sys,Ts,varargin)
%D2D  Resample discrete IDMODEL.
%
%   MOD = D2D(MOD,TS) resamples the discrete-time IDMODEL model MOD 
%   to produce an equivalent discrete system with sample time TS.
%   
%   MOD = D2D(MOD, Ts, METHOD)
%   where METHOD = 'ZOH' or 'FOH' allows overriding the default handling of
%   the transformation method. If you have Control System Toolbox, METHOD
%   can also be set to 'tustin', or 'prewarp'. With the 'prewarp' method,
%   use the syntax:  
%    MOD = D2D(MOD,Ts,'prewarp', Wc), where Wc is the critical
%    frequency. See HELP LTI/D2D for more information. 
%
%   See also D2C, C2D.

%   $Revision: 1.2.2.1 $  $Date: 2009/01/20 15:32:24 $
%   Copyright 1986-2008 The MathWorks, Inc.


sys = d2c(sys,varargin{:});
sys = c2d(sys,Ts,varargin{:});

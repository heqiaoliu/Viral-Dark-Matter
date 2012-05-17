function obj = hsvdOptions(varargin)
%HSVDOPTIONS  Creates option set for the HSVD and BALREAL commands.
%
%   OPT = HSVDOPTIONS returns the default options for HSVD and BALREAL. 
%
%   OPT = HSVDOPTIONS('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported options include:
%
%   AbsTol,RelTol    Absolute and relative tolerances for stable/unstable 
%                    decomposition (defaults: AbsTol=0 and RelTol=1e-8).
%                    For models with unstable poles, HSVD first extracts
%                    the stable dynamics by computing the stable/unstable 
%                    decomposition G -> GS + GU. The "AbsTol" and "RelTol" 
%                    tolerances control the accuracy of this decomposition
%                    by ensuring that the frequency responses of G and GS+GU
%                    differ by no more than AbsTol + RelTol * abs(G). 
%                    Increasing these tolerances helps separate nearby stable 
%                    and unstable modes at the expense of accuracy.
%                       
%   Offset           Offset for the stable/unstable boundary (default = 1e-8).
%                    In the stable/unstable decomposition, the stable term 
%                    includes only poles satisfying
%                       Continuous time:   Re(s) < -Offset * max(1,|Im(s)|)
%                       Discrete time:      |z|  < 1 - Offset
%                    Increase the value of "Offset" to treat poles close to 
%                    the stability boundary as unstable.
%
%   Example:
%      sys = zpk(-.5,[-1e-6 -2],1);
%      opt = hsvdOptions('Offset',.001);
%      hsvd(sys,opt)  % treats -1e-6 as unstable
%
%   See also HSVD, BALREAL, STABSEP.

%   Author(s): P.Gahinet
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $   $Date: 2010/02/08 22:52:30 $
try
   obj = initOptions(ltioptions.hsvd,varargin);
catch E
   throw(E)
end
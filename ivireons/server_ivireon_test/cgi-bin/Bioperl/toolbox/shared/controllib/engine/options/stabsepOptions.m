function obj = stabsepOptions(varargin)
%STABSEPOPTIONS  Creates option set for the STABSEP command.
%
%   OPT = STABSEPOPTIONS returns the default options for the stable/unstable
%   decomposition G -> G1 + G2 computed by [G1,G2] = STABSEP(G). 
%
%   OPT = STABSEPOPTIONS('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported options include:
%
%   Focus            Focus of decomposition [{'stable'} | 'unstable']
%                    This option specifies whether the first output G1 of 
%                    STABSEP should contain only stable dynamics (default)  
%                    or only unstable dynamics.
%
%   AbsTol,RelTol    Absolute and relative tolerances for decomposition
%                    (defaults: AbsTol=0 and RelTol=1e-8). 
%                    The STABSEP algorithm ensures that the frequency   
%                    responses of G and G1+G2 differ by no more than 
%                    AbsTol + RelTol * abs(G). Increasing these tolerances  
%                    helps separate nearby stable and unstable modes at the 
%                    expense of accuracy.
%                       
%   Offset           Offset for the stable/unstable boundary (default = 0).
%                    The first output G1 of STABSEP includes only poles 
%                    satisfying
%                       Continuous time
%                         Focus='stable':   Re(s) < -Offset * max(1,|Im(s)|)
%                         Focus='unstable'  Re(s) >  Offset * max(1,|Im(s)|)
%                       Discrete time
%                         Focus='stable':    |z| < 1 - Offset
%                         Focus='unstable'   |z| > 1 + Offset
%                    Increase the value of "Offset" to exclude poles close to 
%                    the stability boundary from G1.
%
%   Example:
%      G = zpk(-.5,[-1e-6 -2+5i -2-5i],10);
%      opt = stabsepOptions('Offset',.001);
%      [G1,G2] = stabsep(G,opt)  % treats -1e-6 as unstable
%
%   See also STABSEP.

%   Author(s): P.Gahinet
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $   $Date: 2010/02/08 22:52:33 $
try
   obj = initOptions(ltioptions.stabsep,varargin);
catch E
   throw(E)
end
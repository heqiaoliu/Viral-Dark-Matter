function c=cfp_options(varargin)
%Fixed-Point Logging Options
%   This component sets Fixed-Point options similar to those
%   set in the Simulink Fixed Point Interface GUI.  It is 
%   typically used before a Model Simulation component in order
%   to control how the model behaves during simulation.
%
%   See also CFP_BLK_LOOP, CSLSIM, FIXPTDLG

% Copyright 1994-2005 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2005/06/24 10:55:27 $

c=rptgenutil('EmptyComponentStructure','cfp_options');
c=class(c,c.comp.Class,rptcomponent,rptfpmethods,zslmethods);
c=buildcomponent(c,varargin{:});

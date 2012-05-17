function Hd = latticearma(k,v)
%LATTICEARMA Lattice Autoregressive Moving-Average.
%   Hd = DFILT.LATTICEARMA(K, V) constructs a Lattice autoregressive
%   moving-average (ARMA) discrete-time filter object Hd with lattice
%   coefficients K and ladder coefficients V.  If K or V are not specified,
%   the defaults [] and 1. In this case, the filter passes the input
%   through to the output unchanged. For more information on filter objects,
%   see the <a href="matlab:web([matlabroot,'\toolbox\signal\sigdemos\html\dfiltdemo.html'])">Getting Started with Discrete-Time Filters</a> demo.
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point Toolbox,
%   enables fixed-point support. For more information, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\filterdesign\filtdesdemos\html\gsfixedptdemo.html'])">Getting Started with Fixed-Point Filters</a> demo.
%
%   % EXAMPLE
%   [b,a] = butter(3,.5);
%   [k,v] = tf2latc(b,a);
%   Hd = dfilt.latticearma(k,v)
%   realizemdl(Hd); % Requires Simulink
%
%   See also DFILT/STRUCTURES, TF2LATC
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2009/07/27 20:29:22 $
Hd = dfilt.latticearma;

Hd.FilterStructure = 'Lattice Autoregressive Moving-Average (ARMA)';

if nargin>=1
  Hd.Lattice = k;
end
if nargin>=2
  Hd.Ladder = v;
end

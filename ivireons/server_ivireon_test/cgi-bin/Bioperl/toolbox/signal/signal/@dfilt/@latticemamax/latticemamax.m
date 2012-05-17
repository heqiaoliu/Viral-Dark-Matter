function Hd = latticemamax(lattice)
%LATTICEMAMAX Lattice Moving-Average for Maximum Phase.
%   Hd = DFILT.LATTICEMAMAX(K) constructs a Lattice moving-average (MA) for
%   maximum phase discrete-time filter object Hd with lattice coefficients K.
%   If K is not specified, it defaults to []. In this case, the filter
%   passes the input through to the output unchanged. For more information on
%   filter objects, see the <a href="matlab:web([matlabroot,'\toolbox\signal\sigdemos\html\dfiltdemo.html'])">Getting Started with Discrete-Time Filters</a> demo.
%
%   Notice that if the K coefficients define a maximum phase filter, the
%   resulting filter in this structure is maximum phase. If your
%   coefficients do not define a maximum phase filter, placing them in this
%   structure does not produce a maximum phase filter.
%
%   Also, the Filter Design Toolbox, along with the Fixed-Point Toolbox,
%   enables fixed-point support. For more information, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\filterdesign\filtdesdemos\html\gsfixedptdemo.html'])">Getting Started with Fixed-Point Filters</a> demo.
%
%   % EXAMPLE
%   k = [.66 .7 0.44 .33];
%   Hd = dfilt.latticemamax(k)
%   ismax = ismaxphase(Hd)
%   realizemdl(Hd); % Requires Simulink
%
%   See also DFILT/STRUCTURES, TF2LATC
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2009/07/27 20:29:23 $
Hd = dfilt.latticemamax;

Hd.FilterStructure = 'Lattice Moving-Average (MA) For Maximum Phase';

if nargin>=1
  Hd.Lattice = lattice;
end

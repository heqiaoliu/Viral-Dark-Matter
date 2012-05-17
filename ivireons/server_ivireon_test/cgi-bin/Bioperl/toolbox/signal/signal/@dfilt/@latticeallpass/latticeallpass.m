function Hd = latticeallpass(lattice)
%LATTICEALLPASS Lattice Allpass.
%   Hd = DFILT.LATTICEALLPASS(LATTICE) constructs a discrete-time lattice 
%   allpass filter object Hd with lattice coefficients K. If K is not
%   specified, it defaults to []. In this case, the filter passes the input
%   through to the output unchanged. For more information on filter objects,
%   see the <a href="matlab:web([matlabroot,'\toolbox\signal\sigdemos\html\dfiltdemo.html'])">Getting Started with Discrete-Time Filters</a> demo.
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point Toolbox,
%   enables fixed-point support. For more information, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\filterdesign\filtdesdemos\html\gsfixedptdemo.html'])">Getting Started with Fixed-Point Filters</a> demo.
%
%   % EXAMPLE
%   k = [.66 .7 .44];
%   Hd = dfilt.latticeallpass(k)
%   realizemdl(Hd); % Requires Simulink
%
%   See also DFILT/STRUCTURES, TF2LATC
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2009/07/27 20:29:20 $
Hd = dfilt.latticeallpass;

Hd.FilterStructure = 'Lattice Allpass';

if nargin>=1
  Hd.Lattice = lattice;
end

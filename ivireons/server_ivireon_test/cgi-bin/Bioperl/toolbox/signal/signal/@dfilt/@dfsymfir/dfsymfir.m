function Hd = dfsymfir(num)
%DFSYMFIR Direct-Form Symmetric FIR.
%   Hd = DFILT.DFSYMFIR(NUM) constructs a discrete-time, direct-form
%   symmetric FIR filter object Hd, with numerator coefficients NUM. 
%   For more information on filter objects, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\signal\sigdemos\html\dfiltdemo.html'])">Getting Started with Discrete-Time Filters</a> demo.
%  
%   Note that one usually does not construct DFILT filters explicitly.
%   Instead, one obtains these filters as a result from a design using <a
%   href="matlab:help fdesign">FDESIGN</a>. 
%
%   Also, the Filter Design Toolbox, along with the Fixed-Point Toolbox,
%   enables fixed-point support. For more information, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\filterdesign\filtdesdemos\html\gsfixedptdemo.html'])">Getting Started with Fixed-Point Filters</a> demo.
%
%   % EXAMPLE #1: Direct instantiation
%   b = [-0.008 0.06 0.44 0.44 0.06 -0.008];
%   Hd = dfilt.dfsymfir(b)
%   realizemdl(Hd)    % Requires Simulink
%   
%   % EXAMPLE #2: Design an equiripple lowpass filter with default specifications
%   Hd = design(fdesign.lowpass, 'equiripple', 'Filterstructure', 'dfsymfir');
%   fvtool(Hd)        % Analyze filter
%   x = randn(100,1); % Input signal
%   y = filter(Hd,x); % Apply filter to input signal
%
%   See also DFILT/STRUCTURES
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $  $Date: 2009/07/27 20:29:15 $
Hd = dfilt.dfsymfir;
Hd.ncoeffs = 1;
Hd.HiddenStates = 0;
Hd.TapIndex = 0;

Hd.FilterStructure = 'Direct-Form Symmetric FIR';

if nargin>=1
  Hd.Numerator = num;
end

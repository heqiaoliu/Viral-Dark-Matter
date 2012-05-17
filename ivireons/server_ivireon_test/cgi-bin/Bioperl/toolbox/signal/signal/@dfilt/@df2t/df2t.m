function Hd = df2t(num,den)
%DF2T Direct-Form II Transposed.
%   Hd = DFILT.DF2T(NUM, DEN) constructs a discrete-time direct-form II
%   transposed filter object Hd, with numerator coefficients NUM and
%   denominator coefficients DEN. The leading coefficient of the
%   denominator DEN(1) cannot be 0. For more information on filter objects,
%   see the <a href="matlab:web([matlabroot,'\toolbox\signal\sigdemos\html\dfiltdemo.html'])">Getting Started with Discrete-Time Filters</a> demo.
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point Toolbox,
%   enables fixed-point support. For more information, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\filterdesign\filtdesdemos\html\gsfixedptdemo.html'])">Getting Started with Fixed-Point Filters</a> demo.
%
%   Also, notice that direct-form implementations of IIR filters can lead
%   to numerical problems. In many cases, it can be advantageous to avoid 
%   forming the transfer function and to use a <a href="matlab:help dfilt.df2tsos">second-order section</a>
%   implementation.
%
%   % EXAMPLE #1: Direct instantiation
%   [b,a] = butter(4,.5);
%   Hd = dfilt.df2t(b,a)
%
%   % EXAMPLE #2: Design a 10th order lowpass filter in section order sections
%   f = fdesign.lowpass('N,F3dB',10,.5);  % Specifications
%   Hd = design(f, 'butter', 'Filterstructure', 'df2tsos')
%
%   See also DFILT/STRUCTURES.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.5.4.5 $  $Date: 2009/07/27 20:28:56 $
Hd = dfilt.df2t;

Hd.FilterStructure = 'Direct-Form II Transposed';

% Hard code the number of coefficients.
Hd.ncoeffs = [1 1];

if nargin>=1
  Hd.Numerator = num;
end
if nargin>=2
  Hd.Denominator = den;
end

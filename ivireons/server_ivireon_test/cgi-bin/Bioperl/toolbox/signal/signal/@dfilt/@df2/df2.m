function Hd = df2(num,den)
%DF2 Direct-Form II.
%   Hd = DFILT.DF2(NUM, DEN) constructs a discrete-time direct-form II
%   filter object Hd, with numerator coefficients NUM and denominator
%   coefficients DEN. The leading coefficient of the denominator DEN(1)
%   cannot be 0. For more information on filter objects, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\signal\sigdemos\html\dfiltdemo.html'])">Getting Started with Discrete-Time Filters</a> demo.
%
%   Notice that the Filter Design Toolbox, along with the Fixed-Point Toolbox,
%   enables fixed-point support. For more information, see the 
%   <a href="matlab:web([matlabroot,'\toolbox\filterdesign\filtdesdemos\html\gsfixedptdemo.html'])">Getting Started with Fixed-Point Filters</a> demo.
%
%   Also, notice that direct-form implementations of IIR filters can lead
%   to numerical problems. In many cases, it can be advantageous to avoid 
%   forming the transfer function and to use a <a href="matlab:help dfilt.df2sos">second-order section</a>
%   implementation.
%
%   % EXAMPLE #1: Direct instantiation
%   [b,a] = butter(4,.5);
%   Hd = dfilt.df2(b,a)
%
%   % EXAMPLE #2: Design a 10th order lowpass filter in section order sections
%   f = fdesign.lowpass('N,F3dB',10,.5);  % Specifications
%   Hd = design(f, 'butter', 'Filterstructure', 'df2sos')
%
%   See also DFILT/STRUCTURES.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.5.4.5 $  $Date: 2009/07/27 20:28:54 $
Hd = dfilt.df2;

Hd.FilterStructure = 'Direct-Form II';

% Tap Index is a vector of two elements. The first element corresponds to 
% the WRITE index the circular buffer. The second index is not used.
Hd.tapIndex = [0 0];

% Hard code the default number of coefficients to avoid special cases in
% the thissetstates and getstates methods.
Hd.ncoeffs = [1 1];

if nargin>=1
  Hd.Numerator = num;
end
if nargin>=2
  Hd.Denominator = den;
end


function Hd = df1sos(varargin)
%DF1SOS Direct-Form I, Second-Order Sections
%   Hd = DFILT.DF1SOS(SOS) returns a discrete-time, second-order section, 
%   direct form I filter object, Hd, with coefficients given in the SOS 
%   matrix defined in <a href="matlab: help zp2sos">zp2sos</a>.
% 
%   Hd = DFILT.DF1SOS(b1,a1,b2,a2,...) returns a discrete-time, second-order 
%   section, direct form I filter object, Hd, with coefficients for the first 
%   section given in the b1 and a1 vectors, for the second section given in the 
%   b2 and a2 vectors, etc. 
% 
%   Hd = DFILT.DF1SOS(...,g) includes a gain vector g. The elements of g are the 
%   gains for each section. The maximum length of g is the number of sections plus 
%   one. If g is not specified, all gains default to one. For more information
%   on filter objects, see the <a href="matlab:web([matlabroot,'\toolbox\signal\sigdemos\html\dfiltdemo.html'])">Getting Started with Discrete-Time Filters</a> demo.
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
%   [z,p,k] = ellip(4,1,60,.4);                                                  
%   [s,g] = zp2sos(z,p,k);                                                     
%   Hd = dfilt.df1sos(s,g)  
%   realizemdl(Hd)    % Requires Simulink
%
%   % EXAMPLE #2: Design an elliptic lowpass filter with default specifications
%   Hd = design(fdesign.lowpass, 'ellip', 'FilterStructure', 'df1sos');
%   fvtool(Hd)                % Analyze filter
%   input = randn(100,1);       
%   output = filter(Hd,input); % Process data through the Equiripple filter.
%
%   See also DFILT/STRUCTURES.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $  $Date: 2009/07/27 20:28:51 $

Hd = dfilt.df1sos;
Hd.ncoeffs = 6;

Hd.FilterStructure = 'Direct-Form I, Second-Order Sections';

msg = parse_inputs(Hd, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

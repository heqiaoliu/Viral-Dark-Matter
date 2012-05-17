function this = arbmag(varargin)
%ARBMAG   Arbitrary Magnitude filter designer.
%   D = FDESIGN.ARBMAG constructs an arbitrary magnitude filter designer D.
%
%   D = FDESIGN.ARBMAG(SPEC) initializes the filter designer
%   'Specification' property to SPEC.  SPEC is one of the following
%   strings and is not case sensitive:
%
%       'N,F,A'       - Single-band design (default)
%       'N,B,F,A'     - Multi-band design 
%       'Nb,Na,F,A'   - Single-band design (*)
%       'Nb,Na,B,F,A' - Multi-band design (*)
%
%  where 
%       A  - Amplitude Vector
%       B  - Number of Bands
%       F  - Frequency Vector
%       N  - Filter Order
%       Nb - Numerator Order
%       Na - Denominator Order
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. 
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(D) to get a list of design methods
%   available for a given SPEC.
%
%   D = FDESIGN.ARBMAG(SPEC, SPEC1, SPEC2, ...) initializes the filter
%   designer specifications with SPEC1, SPEC2, etc. 
%   Use GET(D, 'DESCRIPTION') for a description of SPEC1, SPEC2, etc.
%
%   D = FDESIGN.ARBMAG(N, F, A) uses the  default SPEC ('N,F,A') and
%   sets the order, the frequency vector, and the amplitude vector.
%
%   D = FDESIGN.ARBMAG(...,Fs) specifies the sampling frequency (in Hz).
%   In this case, all other frequency specifications are also in Hz.
%
%   % Example #1 - Design a single-band arbitrary-magnitude FIR filter
%   N = 120;
%   F = linspace(0,1,100);    
%   As = ones(1,100)-F*0.2;
%   Absorb = [ones(1,30),(1-0.6*bohmanwin(10))',...
%             ones(1,5), (1-0.5*bohmanwin(8))',ones(1,47)];
%   A = As.*Absorb; % Optical Absorption of Atomic Rubidium87 Vapor
%   d = fdesign.arbmag(N,F,A);
%   Hd = design(d);
%   fvtool(Hd)
%
%   % Example #2 - Design a single-band arbitrary-magnitude IIR filter (*)
%   Nb = 12; Na = 10;
%   d  = fdesign.arbmag('Nb,Na,F,A',Nb,Na,F,A);
%   Hd = design(d);
%
%   % Example #3 - Design a multi-band filter for noise shaping when
%   %              simulating a Rayleigh fading wireless communications
%   %              channel (*)
%   Nb = 4; Na = 6;
%   NBands = 2;
%   F1 = 0:0.01:0.4;
%   A1 = 1.0 ./ (1 - (F1./0.42).^2).^0.25;
%   F2 = [.45 1];
%   A2 = [0 0];
%   d  = fdesign.arbmag('Nb,Na,B,F,A',Nb,Na,NBands,F1,A1,F2,A2);
%   Hd = design(d);
%   fvtool(Hd)
%
%   For more information, see the <a href="matlab:web([matlabroot,'\toolbox\filterdesign\filtdesdemos\html\arbmagdemo.html'])">Arbitrary Magnitude Demo</a> (*). 
%
%   (*) Filter Design Toolbox required
%
%   See also FDESIGN, FDESIGN/SETSPECS, FDESIGN/DESIGN.

%   Author(s): V. Pellissier
%   Copyright 2005-08 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/03/09 19:35:22 $

this = fdesign.arbmag;

set(this, 'Response', 'Arbitrary Magnitude');

this.setspecs(varargin{:});

capture(this);

% [EOF]

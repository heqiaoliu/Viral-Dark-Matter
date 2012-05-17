function [s,g] = designbwparameq(this,N,G0,G,GB,Gb,w0,Dwb,varargin)
%DESIGNBWPARAMEQ   

%   Author(s): S. Orfanidis
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:28:37 $

% Note: w0, Dwb must already be passed in to this function multiplied by
% pi!

if w0==0 || w0==pi, N = 2*N; end

DW = hpeqbw(N/2,G0,G,GB,Gb,Dwb,varargin{:});
    
[s,g] = designparameq(this,N,G0,G,GB,w0,DW,varargin{:});


%%
function Dw = hpeqbw(N,G0,G,GB,Gb,Dwb,type,Gs)
%hpeqbw - bandwidth remapping for high-order digital parametric equalizer
%
% Usage: Dw = hpeqbw(N,G0,G,GB,Gb,Dwb,type,Gs); 
%
%        Dw = hpeqbw(N,G0,G,GB,Gb,Dwb);          Butterworth (equivalent to type=0)
%        Dw = hpeqbw(N,G0,G,GB,Gb,Dwb,0);        Butterworth
%        Dw = hpeqbw(N,G0,G,GB,Gb,Dwb,1);        Chebyshev-1
%        Dw = hpeqbw(N,G0,G,GB,Gb,Dwb,2);        Chebyshev-2
%        Dw = hpeqbw(N,G0,G,GB,Gb,Dwb,3,Gs);     Elliptic
%
% N   = analog filter order
% G0  = reference gain (all gains must be in dB, enter -inf to get 0 in absolute units)
% G   = peak/cut gain 
% GB  = bandwidth gain
% Gb  = intermediate gain (e.g., 3-dB below G)
% Dwb = bandwidth at level Gb (in units of radians/sample)
% type = 0,1,2,3, for Butterworth, Chebyshev-1, Chebyshev-2, and Elliptic (default is type=0)
% Gs = stopband gain in dB, for elliptic case only
%
% Dw = bandwidth at level GB (rads/sample)
%
% notes: given bandwidth Dwb at level Gb, it computes Dw at the design level GB
%
%        the computed Dw may be used in HPEQ to design the filter, that is, 
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,type,Gs,tol);
%
%        it solves the magnitude equation: (G^2 + G0^2*e^2*FN(wb)^2)/(1 + e^2*FN(wb)^2) = Gb^2  
%        for wb = Wb/WB, where Wb = tan(Dwb/2) and WB = tan(Dw/2), and computes Dw = 2*atan(Wb/wb)
%        
%        boost: G0<Gs<Gb<GB<G  (type=0,1,3),  G0<GB<Gb<G (type=2)
%        cut:   G0>Gs>Gb>GB>G  (type=0,1,3),  G0>GB>Gb>G (type=2)
%
%        example: G0=0; G=12; GB=11.99; Gs=0.01; Gb=9 = 3-dB below peak   
%                 N=4; type = 3; w0 = 0.3*pi; Dwb = 0.2*pi; [w1,w2] = bandedge(w0,Dwb);
%                 Dw = hpeqbw(N,G0,G,GB,Gb,Dwb,3,Gs); [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,3,Gs);
%                 f=linspace(0,1,1001); H=20*log10(abs(fresp(B,A,pi*f))); 
%                 plot(f,H, [w1,w2]/pi,[Gb,Gb],'r.'); grid; ytick(0:1:12); xtick(0:0.1:1);
%
%        it uses the functions ELLIPDEG, ACDE, CDE

if nargin==6, type=0; end
if type==3 && nargin==7, disp('must enter value for Gs'); return; end

G0 = 10^(G0/20); G = 10^(G/20); GB = 10^(GB/20); Gb = 10^(Gb/20);
if nargin==8, Gs = 10^(Gs/20); end

e = sqrt((G^2-GB^2)/(GB^2-G0^2)); 
eb = sqrt((G^2-Gb^2)/(Gb^2-G0^2));
 
Fb = eb/e;                % Fb = FN(wb), where wb = Wb/WB

switch type,
   case 0,
      wb = Fb^(1/N);
   case 1,
      u = acos(Fb)/N; wb = cos(u);
   case 2,
      u = acos(1/Fb)/N; wb = 1/cos(u);
   case 3,
      tol = eps;                              % may be changed, e.g., tol=1e-15, or, tol=5 Landen iterations
      es = sqrt((G^2-Gs^2)/(Gs^2-G0^2)); 
      k1 = e/es; 
      k = ellipdeg(N,k1,tol);
      u = acde(Fb,k1,tol)/N; wb = cde(u,k,tol);   
end

Wb = tan(Dwb/2);
WB = Wb/wb;  
Dw = 2*atan(WB);


% [EOF]

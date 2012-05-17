function [s,g] = designparameq(this,N,G0,G,GB,w0,DW,varargin)
%DESIGNPARAMEQ   

%   Author(s): S. Orfanidis and R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:28:40 $

if rem(N,2),
    % Error for odd orders 
    error(generatemsgid('oddOrder'),'Filter order must be even.');
end

[B,A] = hpeq(N/2,G0,G,GB,w0,DW,varargin{:});

% Check if already second-order (lowpass or highpass case)
if all(all(B(:,4:5)==0)) && all(all(A(:,4:5)==0)),
    s = [B(:,1:3)./repmat(B(:,1),1,3),A(:,1:3)];
    g = [B(:,1);1];
else
    
    fog = B(:,1); % Fourth-order gains

    for k = 1:size(B,1),
        B(k,:) = B(k,:)/B(k,1);
    end
    
    % Discard trivial sections that may be returned by hpeq
    trivialsec = false;
    if B(1,1) == 1 && all(B(1,2:end)==0) && A(1,1) == 1 && all(A(1,2:end)==0),
        B(1,:) = [];
        A(1,:) = [];
        if fog(1) ~= 1,
            trivialsec = true;
            g0 = fog(1);            
        end
        fog = fog(2:end);
    end

    % Strip out any possible second-order sections
    sosflag = false;
    if all(B(1,4:5)==0) && all(A(1,4:5)==0),
        sosflag = true;
        s1 = [B(1,1:3),A(1,1:3)];
        B(1,:)=[]; A(1,:)=[];
        g1 = fog(1);
        fog = fog(2:end);
    end

    % Initialize matrix
    [s,g] = sosinitbpbs(this,N,A(:,2),A(:,3),A(:,4),A(:,5),fog);

    % Form SOS numerators
    msf = floor(N/4);
    for k = 1:2:2*msf-1,
        r = roots(B(ceil(k/2),:));
        p1 = poly(r(1:2));
        p2 = poly(r(3:4));
        s(k,2:3) = p1(2:3);
        s(k+1,2:3) = p2(2:3);
    end
    if sosflag,
        s(end,:) = s1;
        g(end) = g1;
    end
    if trivialsec,
        g = [g0;g];
    end
end
%%
function [B,A,Bh,Ah] = hpeq(N, G0, G, GB, w0, Dw, type, Gs, tol)
% hpeq - high-order digital parametric equalizer design
%
% Usage: [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,type,Gs,tol); 
%
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw);            Butterworth
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,0);          Butterworth
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,1);          Chebyshev-1
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,2);          Chebyshev-2
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,3,Gs,tol);   elliptic, e.g., tol = 1e-8
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,3,Gs,M);     elliptic, tol = M = Landen iterations, e.g., M=5
%        [B,A,Bh,Ah] = hpeq(N,G0,G,GB,w0,Dw,3,Gs);       elliptic, default tol = eps
%
% N  = analog filter order
% G0 = reference gain (all gains must be in dB, enter -Inf to get 0 in absolute units)
% G  = peak/cut gain
% GB = bandwidth gain
% w0 = peak/cut center frequency in units of radians/sample, i.e., w0=2*pi*f0/fs
% Dw = bandwidth in radians/sample, (if w0=pi, Dw = cutoff freq measured from Nyquist)
% type = 0,1,2,3, for Butterworth, Chebyshev-1, Chebyshev-2, and elliptic (default is type=0)
% Gs = stopband gain, for elliptic case only
% tol = tolerance for elliptic case, e.g., tol = 1e-10, default value is tol = eps = 2.22e-16
%
% B,A   = rows are the numerator and denominator 4th order section coefficients of the equalizer
% Bh,Ah = rows are the numerator and denominator 2nd order coefficients of the lowpass shelving filter
%
% notes: G,GB,G0 are in dB and converted internally to absolute units, e.g. G => 10^(G/20)
%
%        gains must satisfy: G0<Gs<GB<G (boost), or, G0>Gs>GB>G (cut)  (exchange roles of Gs,GB for Cheby-2)
% 
%        w0 = 2*pi*f0/fs, Dw = 2*pi*Df/fs, with f0,Df,fs in Hz
% 
%        B,A have size (L+1)x5, and Bh,Ah, size (L+1)x3, where L=floor(N/2)
%        when N is even, the first row is just a gain factor
%
%        left and right bandedge frequencies: [w1,w2] = bandedge(w0,Dw)
%        for the stopband in the elliptic case: [w1s,w2s] = bandedge(w0,Dws), where 
%        k = ellipdeg(N,k1,tol); WB = tan(Dw/2); Ws = WB/k; Dws = 2*atan(Ws)
%
% see also, BLT, ELLIDPEG, ELLIPK, ASNE, CDE, BANDEDGE, HPEQBW, OCTBW

if nargin==6, type=0; end
if type==3 && nargin<=7, disp('must enter values for Gs,tol'); return; end
if type==3 && nargin==8, tol=eps; end

G0 = 10^(G0/20); G = 10^(G/20); GB = 10^(GB/20); if type==3, Gs = 10^(Gs/20); end

r = rem(N,2); L = (N-r)/2;

%Bh = [1 0 0]; Ah = [1 0 0]; A = [1 0 0 0 0]; B = [1 0 0 0 0];

if G==G0,                             % no filtering if G=G0
   Bh = G0*[1 0 0];     Ah = [1 0 0]; 
   B  = G0*[1 0 0 0 0]; A  = [1 0 0 0 0];
   return; 
end              

c0 = cos(w0); 

if w0==0,    c0=1;  end    % special cases
if w0==pi/2, c0=0;  end
if w0==pi,   c0=-1; end

WB = tan(Dw/2);
e = sqrt((G^2 - GB^2)/(GB^2 - G0^2)); 

g = G^(1/N); g0 = G0^(1/N); 

switch type
  case 0,
    a = e^(1/N);
    b = g0*a;
  case 1,
    eu = (1/e + sqrt(1+1/e^2))^(1/N);
    ew = (G/e + GB*sqrt(1+1/e^2))^(1/N);
    a = (eu - 1/eu)/2;			
    b = (ew - g0^2/ew)/2;	              
  case 2,
    eu = (e + sqrt(1+e^2))^(1/N);
    ew = (G0*e + GB*sqrt(1+e^2))^(1/N);
    a = (eu - 1/eu)/2;
    b = (ew - g^2/ew)/2;
  case 3,
    es = sqrt((G^2 - Gs^2)/(Gs^2 - G0^2)); 
    k1 = e/es;
    k = ellipdeg(N, k1, tol);
    if G0~=0, 
       ju0 = asne(j*G/e/G0, k1, tol)/N;    % not used when G0=0
    end    
    jv0 = asne(j/e, k1, tol)/N;
end

if r==0,
  switch type
    case {0,1,2}
      Ba(1,:) = [1, 0, 0]; 
      Aa(1,:) = [1, 0, 0];
    case 3
      Ba(1,:) = [1, 0, 0] * GB;
      Aa(1,:) = [1, 0, 0];
   end
end 
     
if r==1,
  switch type
    case 0
      Ba(1,:) = [g*WB, b, 0]; 
      Aa(1,:) = [WB,   a, 0];
    case 1
      Ba(1,:) = [b*WB, g0, 0]; 
      Aa(1,:) = [a*WB, 1,  0]; 
    case 2
      Ba(1,:) = [g*WB, b, 0]; 
      Aa(1,:) = [WB,   a, 0];
    case 3
      if G0==0 && G~=0,
         B00 = G*WB; B01 = 0;
      elseif G0~=0 && G==0,
         K=ellipk(k,tol); K1=ellipk(k1,tol); 
         B00 = 0; B01 = G0*e*N*K1/K;
      else                                  % G0~=0 and G~=0
         z0 = real(j*cde(-1+ju0,k,tol));    % it's supposed to be real
         B00 = G*WB; B01 = -G/z0;
      end    
      p0 = real(j*cde(-1+jv0,k,tol));
      A00 = WB; A01 = -1/p0;
      Ba(1,:) = [B00,B01,0];
      Aa(1,:) = [A00,A01,0];
   end
end 

if L>0, 
   i = (1:L)';
   ui = (2*i-1)/N;  
   ci = cos(pi*ui/2); si = sin(pi*ui/2);
   v = ones(L,1);

   switch type
      case 0,
        Ba(1+i,:) = [g^2*WB^2*v, 2*g*b*si*WB, b^2*v];
        Aa(1+i,:) = [WB^2*v, 2*a*si*WB, a^2*v];
      case 1,
        Ba(1+i,:) = [WB^2*(b^2+g0^2*ci.^2), 2*g0*b*si*WB, g0^2*v];
        Aa(1+i,:) = [WB^2*(a^2+ci.^2), 2*a*si*WB, v];
      case 2,
        Ba(1+i,:) = [g^2*WB^2*v, 2*g*b*si*WB, b^2+g^2*ci.^2];
        Aa(1+i,:) = [WB^2*v, 2*a*si*WB, a^2+ci.^2];
      case 3,
        if G0==0 && G~=0,
           zeros = j ./ (k*cde(ui,k,tol));
        elseif G0~=0 && G==0,
           zeros = j*cde(ui,k,tol);
        else                               % G0~=0 and G~=0
           zeros = j*cde(ui-ju0,k,tol);
        end
        poles = j*cde(ui-jv0,k,tol);
        Bi0 = WB^2*v; Bi1 = -2*WB*real(1./zeros); Bi2 = abs(1./zeros).^2; 
        Ai0 = WB^2*v; Ai1 = -2*WB*real(1./poles); Ai2 = abs(1./poles).^2;
        Ba(1+i,:) = [Bi0, Bi1, Bi2];
        Aa(1+i,:) = [Ai0, Ai1, Ai2];
   end
end

[B,A,Bh,Ah] = blt(Ba,Aa,w0);

%%
function [B,A,Bhat,Ahat] = blt(Ba,Aa,w0)
% blt - bilinear transformation of analog second-order sections
%
% Usage: [B,A,Bhat,Ahat] = blt(Ba,Aa,w0);
%
% Ba,Aa = Kx3 matrices of analog numerator and denominator coefficients (K sections)
% w0    = center frequency in radians/sample 
%
% B,A = Kx5 matrices of numerator and denominator coefficients (4th-order sections in z)
% Bhat,Ahat = Kx3 matrices of 2nd-order sections in the variable zhat
%
% notes: It implements the two-stage bilinear transformation: 
%                       s    -->    zhat    -->    z
%                  LP_analog --> LP_digital --> BP_digital
%
%        s = (zhat-1)/(zhat+1) = (z^2 - 2*c0*z + 1)/(z^2 - 1), with zhat = z*(c0-z)/(1-c0*z)
%
%        c0 = cos(w0), where w0 = 2*pi*f0/fs = center frequency in radians/sample
%
%        (B0 + B1*s + B2*s^2)/(A0 + A1*s + A2*s^2) = 
%        (b0h + b1h*zhat^-1 + b2h*zhat^-2)/(1 + a1h*zhat^-1 + a2h*zhat^-2) =
%        (b0 + b1*z^-1 + b2*z^-2 + b3*z^-3 + b4*z^-4)/(1 + a1*z^-1 + a2*z^-2 + a3*z^-3 + a4*z^-4)
%
%        column-wise, the input and output matrices have the forms:
%        Ba = [B0,B1,B2], Bhat = [b0h, b1h, b2h], B = [b0,b1,b2,b3,b4]
%        Aa = [A0,A1,A2], Ahat = [1,   a1h, a2h], A = [1, a1,a2,a3,a4]
           
if nargin==0, help blt; return; end

K = size(Ba,1);         % number of sections

B = zeros(K,5); A = zeros(K,5);
Bhat = zeros(K,3); Ahat = zeros(K,3); 

B0 = Ba(:,1); B1 = Ba(:,2); B2 = Ba(:,3);       % simplify notation
A0 = Aa(:,1); A1 = Aa(:,2); A2 = Aa(:,3);       % A0 may not be zero

c0 = cos(w0);       

if w0==0,    c0=1;  end;                        % make sure special cases are computed exactly
if w0==pi;   c0=-1; end;
if w0==pi/2; c0=0;  end;

i = find((B1==0 & A1==0) & (B2==0 & A2==0));    % find 0th-order sections (i.e., gain sections)

Bhat(i,1) = B0(i)./A0(i);
Ahat(i,1) = 1;

B(i,1) = Bhat(i,1);
A(i,1) = 1;

i = find((B1~=0 | A1~=0) & (B2==0 & A2==0));    % find 1st-order analog sections

D = A0(i)+A1(i);
Bhat(i,1) = (B0(i)+B1(i))./D;
Bhat(i,2) = (B0(i)-B1(i))./D;
Ahat(i,1) = 1;
Ahat(i,2) = (A0(i)-A1(i))./D;

B(i,1) = Bhat(i,1); 
B(i,2) = c0*(Bhat(i,2)-Bhat(i,1));
B(i,3) = -Bhat(i,2);
A(i,1) = 1;
A(i,2) = c0*(Ahat(i,2)-1);
A(i,3) = -Ahat(i,2);

i = find(B2~=0 | A2~=0);                        % find 2nd-order analog sections

D = A0(i)+A1(i)+A2(i);
Bhat(i,1) = (B0(i)+B1(i)+B2(i))./D;
Bhat(i,2) = 2*(B0(i)-B2(i))./D;
Bhat(i,3) = (B0(i)-B1(i)+B2(i))./D;
Ahat(i,1) = 1;
Ahat(i,2) = 2*(A0(i)-A2(i))./D;
Ahat(i,3) = (A0(i)-A1(i)+A2(i))./D;

B(i,1) = Bhat(i,1);
B(i,2) = c0*(Bhat(i,2)-2*Bhat(i,1));
B(i,3) = (Bhat(i,1)-Bhat(i,2)+Bhat(i,3))*c0^2 - Bhat(i,2);
B(i,4) = c0*(Bhat(i,2)-2*Bhat(i,3));
B(i,5) = Bhat(i,3);

A(i,1) = 1;
A(i,2) = c0*(Ahat(i,2)-2);
A(i,3) = (1-Ahat(i,2)+Ahat(i,3))*c0^2 - Ahat(i,2);
A(i,4) = c0*(Ahat(i,2)-2*Ahat(i,3));
A(i,5) = Ahat(i,3);

if c0==1 || c0==-1 	        % LP or HP shelving filter
   B = Bhat;                    % B,A are second-order
   A = Ahat;
   B(:,2) = c0*B(:,2);	        % change sign if w0=pi
   A(:,2) = c0*A(:,2);
   B(:,4:5) = 0;                % make them (K+1)x5
   A(:,4:5) = 0;                % for convenience in using fresp
end    

% [EOF]

function [Roots,Gains,RLInfo] = rlocus(D,Gains,varargin)
% Generates gains and roots for root locus plot.
%
%  Optional third argument 'refine' instructs algorithm 
%  to refine supplied grid with critical values such as 
%  such as the gains for which branches cross.

%  Author(s): P. Gahinet
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:24 $

% Make GAINS a row vector
ni = nargin;
GainSupplied = (ni>1 && ~isempty(Gains));
if GainSupplied
   Gains = reshape(Gains,[1 length(Gains)]);
end

% Reduce improper case to proper case by transforming gain->1/gain 
% and inverting SYS
[IsProper,D] = isproper(D);
if ~IsProper
   D = inv(D);
end

% Compute open-loop dynamics and adequate/consistent state-space
% realization for root locus generation
[a,b,c,d,OLz,OLp,OLk] = utGetLoopData(ss(D));
Ts = D.Ts;

% Generate root locus
if GainSupplied,
   % Derive gain vector
   if ni>2
      % Add gain values where branches cross (for more smoothness)
      ExtraGains = rlocmult(OLz,OLp,OLk);
      if IsProper
         Gains = unique([Gains,ExtraGains]);
      else
         Gains = unique([Gains,LocalInvertGains(ExtraGains)]);
      end
   end
   % Compute the roots at the specified gains (output is NS by length(Gains))
   if IsProper
      Roots = genrloc(a,b,c,d,Gains,OLz,OLp,'sort');
   else
      Roots = genrloc(a,b,c,d,LocalInvertGains(Gains),OLz,OLp,'sort');
   end
      
elseif OLk==0 || (isempty(OLz) && isempty(OLp))
   % Limit cases
   Roots = [];  
   Gains = zeros(1,0);
   
else
   % Adaptively generate gain values if they are not specified
   [Gains,Roots] = gainrloc(a,b,c,d,OLz,OLp,OLk,Ts);
   if ~IsProper
      Gains = fliplr(LocalInvertGains(Gains));
      Roots = fliplr(Roots);
   end
end

% Return open-loop info for subsequent computations
if nargout>2
   % Return
   %   * Hessenberg form (helps compute closed-loop poles that are 
   %     consistent with root locus branches, see g297998)
   %   * ZPK data
   %   * Flag indicating when this data is for the inverse
   %     of the open-loop transfer (improper case)
   RLInfo = struct(...
      'InverseFlag',~IsProper,...
      'a',a,...
      'b',b,...
      'c',c,...
      'd',d,...
      'Zero',OLz,...
      'Pole',OLp,...
      'Gain',OLk);
end

%---------------------------------------------------------

function Gains = LocalInvertGains(Gains)
% Transforms Gains -> 1/Gains
isz = (Gains==0);
Gains(:,isz) = Inf;
Gains(:,~isz) = 1./Gains(:,~isz);

function [NumStr, DenStr] = getDisplayString(this)
% getDisplayString  This function generates the strings for the numerator
% and denominator for displaying the compensator in the pzeditor panel and
% automated tuning panel

%   Author(s): P. Gahinet
%   Revised: C. Buhr, R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/09/30 00:16:58 $

% get format and ts
Format = this.Format;
Ts = this.Ts;
% Get ZPK data
D = zpk(this);
Z = D.z{1};
P = D.p{1};

% if pure gain, don't show num and den
if isempty(Z) && isempty(P)
   % Pure gain
   NumStr = '';
   DenStr = '';
else
   % Generate num,den strings
   NumStr = LocalFormat(Z,Ts,Format);
   DenStr = LocalFormat(P,Ts,Format);
end
   
%-------------------------Helper Functions----------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalFormat %%%
%%%%%%%%%%%%%%%%%%%
function str = LocalFormat(P,Ts,Format)
% Formats display
Format = lower(Format);  

% Defaults
str = '';
if Ts == 0
    Var = 's';
elseif strcmp(Format(1), 'z')
    % ZeroPoleGain format
    Var = 'z';
else
    Var = 'w';
    P = (P-1)/Ts;  % Equivalent s-domain root is (z-1)/Ts 
end

% Sort roots
P = [P(~imag(P),:) ; P(imag(P)>0,:)];

% Put roots at the origin (s=0 or z=1) upfront
if strcmp(Var,'z')
   indint = find(P==1);
else
   indint = find(P==0);
end
nint = length(indint);
P(indint,:) = [];
switch Var
case {'s','w'}
   if nint>1
      str = sprintf('%s^%d',Var,nint);
   elseif nint==1
      str = Var;
   end
case 'z'
   if nint>1
      str = sprintf('(z-1)^%d',nint);
   elseif nint==1
      str = sprintf('(z-1)');
   end
end
   
% Loop over remaining roots
Signs = {'+','-'};
switch Format
case 'zeropolegain'  % zero/pole/gain
   for ct = 1:length(P)
      Pct = P(ct);
      SignType = Signs{1+(real(Pct)>0)};
      if ~imag(Pct),
         if real(Pct)
            NextStr = sprintf('(%s %s %0.3g)',Var,SignType,abs(real(Pct)));
         else
            NextStr = Var;
         end
      else
         if real(Pct)
            NextStr = sprintf('(%s^2 %s %0.3g%s + %0.3g)',Var,SignType,...
               2*abs(real(Pct)),Var,(real(Pct)^2+imag(Pct)^2));
         else
            NextStr = sprintf('(%s^2 + %0.3g)',Var,real(Pct)^2+imag(Pct)^2);
         end
      end
      str = sprintf('%s %s',str,NextStr);
   end
   
case 'timeconstant1'  % time constant 1, i.e., (1 + Tp s)
    for ct = 1:length(P)
        Pct = P(ct);
        SignType = Signs{1+(real(Pct)>0)};
        if ~imag(Pct),
            % Real root
            rp = 1/abs(real(Pct));
            if rp==1, 
                NextStr = sprintf('(1 %s %s)',SignType,Var);
            else
                NextStr = sprintf('(1 %s %0.2g%s)',SignType,rp,Var);
            end
        elseif real(Pct)
            % Complex root with nonzero real part
            w = abs(Pct);
            rp = 2*abs(real(Pct))/w^2;
            if w==1, 
                NextStr = sprintf('(1 %s %0.2g%s + %s^2)',SignType,rp,Var,Var);
            else         
                NextStr = sprintf('(1 %s %0.2g%s + (%0.2g%s)^2)',SignType,rp,Var,1/w,Var);
            end
        else
            % Root j*b
            NextStr = sprintf('(1 + (%0.2g%s)^2)',1/abs(Pct),Var);
        end
        str = sprintf('%s %s',str,NextStr);
    end
    
case 'timeconstant2'  % time constant 2 (natural frequency), i.e., (1 + s/p)
    for ct = 1:length(P)
        Pct = P(ct);
        SignType = Signs{1 + (real(Pct)>0)};
        if ~imag(Pct)
            % Real root
            rp = abs(real(Pct));
            if rp == 1, 
                NextStr = sprintf('(1 %s %s)', SignType, Var);
            else
                NextStr = sprintf('(1 %s %s/%0.2g)', SignType, Var, rp);
            end
        elseif real(Pct)
            % Complex root with nonzero real part
            wn = sqrt(real(Pct)^2 + imag(Pct)^2);
            rp = 2 * abs(real(Pct)) / wn;
            if wn == 1
                NextStr = sprintf('(1 %s %0.2g%s + %s^2)', ...
                    SignType, rp, Var, Var);
            else         
                NextStr = sprintf('(1 %s %0.2g%s/%0.2g + (%s/%0.2g)^2)', ...
                    SignType, rp, Var, wn, Var, wn);
            end
        else
            % Complex root with zero real part (root j*b)
            NextStr = sprintf('(1 + (%s/%0.2g)^2)', Var, abs(Pct));
        end
        str = sprintf('%s %s', str, NextStr);
    end
    
end

% Set string to 1 if no root
if isempty(str)
    str = '1';
end

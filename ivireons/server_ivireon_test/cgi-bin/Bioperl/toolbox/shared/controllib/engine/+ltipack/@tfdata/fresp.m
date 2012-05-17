function [h,InfResp] = fresp(D,w)
% Frequency response of TF model.

%	 Author(s): P.Gahinet 
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:38 $
[ny,nu] = size(D.num);

% Form vector s of complex frequencies
s = ltipack.utGetComplexFrequencies(w,D.Ts);
infs = isinf(s);  % s = Inf
gt1 = (abs(s)>1);
iinf = find(infs);  % s=inf
igt1 = find(~infs & gt1);  % |s|>1
ile1 = find(~infs & ~gt1); % |s|<=1
sgti = 1./s(igt1); sle = s(ile1); 

% Compute frequency response of H(s)
h = zeros(length(s),ny,nu); % More convenient for loop below
InfResp = false;
for ct=1:ny*nu
   num = D.num{ct};
   den = D.den{ct};
   % Guard against preventable under- and overflow (see g320760)
   inum = find(num~=0);
   iden = find(den~=0);
   if ~isempty(inum)
      % Response at s=Inf
      if den(1)==0
         h(iinf,ct) = Inf;
      else
         h(iinf,ct) = num(1)/den(1);
      end
      num = num(inum(1):inum(end));
      den = den(iden(1):iden(end));
      % Response for |s|>1
      numval = polyval(fliplr(num),sgti);
      denval = polyval(fliplr(den),sgti);
      spower = sgti.^(inum(1)-iden(1));
      isSingularGT = (denval==0);
      ins = find(~isSingularGT);
      if ~isempty(ins)
         h(igt1(ins),ct) = spower(ins) .* numval(ins) ./ denval(ins);
      end
      % Response for |s|<=1
      numval = polyval(num,sle);
      denval = polyval(den,sle);
      spower = sle.^(iden(end)-inum(end));
      isSingularLE = (denval==0);
      ins = find(~isSingularLE); 
      if ~isempty(ins)
         h(ile1(ins),ct) = spower(ins) .* numval(ins) ./ denval(ins);
      end
      % Singular frequencies
      idx = [igt1(isSingularGT) ; ile1(isSingularLE)];
      if ~isempty(idx)
         InfResp = true;
         h(idx,ct) = Inf;
      end
   end
end

% Reorder dimensions and cleanup NaN's
h = permute(h,[2 3 1]);
h(isnan(h)) = NaN;

% Factor in delays
if hasdelay(D)
   h = getDelayResp(D,h,s);
end

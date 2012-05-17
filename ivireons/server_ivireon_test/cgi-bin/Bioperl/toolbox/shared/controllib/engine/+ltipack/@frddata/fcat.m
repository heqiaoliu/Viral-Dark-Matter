function D = fcat(D,D2)
% Concatenates frequency vectors
% Note: D and D2 are commensurate arrays of frddata objects.
nsys = numel(D);
if nsys==0
   return
end

% Enforce common units
unit = D(1).FreqUnits;
unit2 = D2(1).FreqUnits;
if strcmp(unit,unit2)
   freqs = D(1).Frequency;
   freqs2 = D2(1).Frequency;
else
   freqs = unitconv(D(1).Frequency,unit,'rad/s');
   freqs2 = unitconv(D2(1).Frequency,unit2,'rad/s');
   unit = 'rad/s';
end
   
% Combine frequency vectors
nf = length(freqs);
[freqs,~,ib] = unique([freqs;freqs2]);
if length(freqs)<nf+length(freqs2)
   ctrlMsgUtils.error('Control:combination:fcat3')
end

% Combine data
for j=1:nsys
   Dj = D(j);  D2j = D2(j);
   % Absorb delays in frequency response when they don't match
   if ~isequal(Dj.Delay,D2j.Delay)
      Dj = elimDelay(Dj,Dj.Delay.Input,Dj.Delay.Output,Dj.Delay.IO);
      D2j = elimDelay(D2j,D2j.Delay.Input,D2j.Delay.Output,D2j.Delay.IO);  
   end
   % Combine responses
   Dj.Frequency = freqs;
   Dj.FreqUnits = unit;
   Dj.Response(:,:,ib) = cat(3,Dj.Response,D2j.Response);
   D(j) = Dj;
end

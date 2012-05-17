function update(cd,r)
%UPDATE  Data update method @AllStabilityMarginData class

%  Author(s): John Glass
%   Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:14 $

rdata = cd.Parent;
if length(r.RowIndex)==1 && length(r.ColumnIndex)==1
   freq = unitconv(rdata.Frequency,rdata.FreqUnits,'rad/s');
   Focus = unitconv(rdata.Focus,rdata.FreqUnits,'rad/s');
   try
      % Compute margins from model data
      r.DataSrc.getmargin('all',cd,find(r.Data==rdata),freq);
   catch
      % Compute margins from response data (IMARGIN)
      % If the response data type is resppack.freqdata, (i.e. Nyquist),
      % then convert to magnitude and phase.  Otherwise use the magnitude
      % and phase from the response data.
      if isa(rdata,'resppack.freqdata')
         mag = abs(rdata.Response);
         phase = unitconv(unwrap(angle(rdata.Response)),'rad','deg');
      else
         mag = unitconv(rdata.Magnitude,rdata.MagUnits,'abs');
         phase = unitconv(rdata.Phase,rdata.PhaseUnits,'deg');
      end
      
      % Compute gain and phase margins
      Margins = allmargin(mag,phase,freq,rdata.Ts,0);
      
      % Eliminate NaN crossings
      idxf = find(isfinite(Margins.GMFrequency));
      cd.GMFrequency = Margins.GMFrequency(:,idxf);
      cd.GainMargin = Margins.GainMargin(:,idxf);
      idxf = find(isfinite(Margins.PMFrequency));
      cd.PMFrequency = Margins.PMFrequency(:,idxf);
      cd.PhaseMargin = Margins.PhaseMargin(:,idxf);
      cd.DelayMargin = Margins.DelayMargin(:,idxf);
      cd.Ts = rdata.Ts;
      cd.Stable = NaN;
   end
   
   % Extend frequency focus by up to two decades to include margin markers
   MarginFreqs = [cd.GMFrequency cd.PMFrequency cd.DMFrequency];
   if isempty(Focus)
      MarginFreqs = MarginFreqs(:,isfinite(MarginFreqs) & MarginFreqs>0);
      Focus = [min(MarginFreqs)/2,2*max(MarginFreqs)];
   else
      MarginFreqs = MarginFreqs(:,MarginFreqs >= max(rdata.Frequency(1),Focus(1)/100) & ...
         MarginFreqs <= min(rdata.Frequency(end),Focus(2)*100));
      Focus = [min([Focus(1),MarginFreqs]),max([Focus(2),MarginFreqs])];
   end
   rdata.Focus = unitconv(Focus,'rad/s',rdata.FreqUnits);
   
else
   cd.GMFrequency = zeros(1,0);
   cd.GainMargin = zeros(1,0);
   cd.PMFrequency = zeros(1,0);
   cd.PhaseMargin = zeros(1,0); 
   cd.DMFrequency = zeros(1,0);
   cd.DelayMargin = zeros(1,0);   
end

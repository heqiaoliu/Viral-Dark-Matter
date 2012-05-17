function updateProps(this,OptionsBox)
% Updates the Java Dialog based on the Data property of the EditBox.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:15:12 $

  
s = get(OptionsBox.GroupBox,'UserData');
Data = OptionsBox.Data; PropChanged = fieldnames(Data);
for ct = 1:length(PropChanged)
   switch PropChanged{ct}
   case  'FrequencyUnits'
      s.FrequencyUnits.select(strcmpi(OptionsBox.Data.FrequencyUnits(1),'r'));
   case  'MagnitudeUnits'
      if strcmpi(OptionsBox.Data.MagnitudeUnits(1),'d')
         Data.MagnitudeScale = 'linear';
         s.MagnitudeScale.select(strcmpi(Data.MagnitudeScale,'log'));
         s.MagnitudeUnits.select(0);
         awtinvoke(s.MagnitudeScalePanel,'setVisible(Z)',false);
      else
         s.MagnitudeUnits.select(1);
         awtinvoke(s.MagnitudeScalePanel,'setVisible(Z)',true);
      end
   case 'PhaseUnits'
      s.PhaseUnits.select(strcmpi(OptionsBox.Data.PhaseUnits(1),'r'));
   case 'MagnitudeScale'
      s.MagnitudeScale.select(strcmpi(OptionsBox.Data.MagnitudeScale,'log'));
   case 'FrequencyScale'
      s.FrequencyScale.select(strcmpi(OptionsBox.Data.FrequencyScale,'log'));
   end
end
GL = java.awt.GridLayout(s.Units.getComponentCount,1,0,3);
s.Units.setLayout(GL);
s.Scale.setLayout(GL);
OptionsBox.Data = Data;
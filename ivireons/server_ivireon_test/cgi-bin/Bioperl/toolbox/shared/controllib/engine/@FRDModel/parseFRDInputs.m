function [Model,freq,unit] = parseFRDInputs(FRDfcn,InputList)
% Helper function for xFRD(MODEL,...). 
% 
% Parses input list and consolidates the signatures xFRD(MODEL,W), 
% xFRD(MODEL,W,UNIT), and xFRD(MODEL,W,'*Unit*',U). Also checks 
% compatibility of the frequency vectors if MODEL is already an
% FRD model.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:43 $
Model = InputList{1};
ni = numel(InputList);
if ni==1 && isa(Model,'FRDModel')
   % Converting other FRD model to FRD
   freq = Model.Frequency;  unit = Model.FrequencyUnit;  return
elseif ni<2 || ni>4
   ctrlMsgUtils.error('Control:transformation:frd1',FRDfcn,FRDfcn)
elseif ni==4 && isempty(strfind(lower(InputList{3}),'unit'))
   % Four-input call is deprecated and should be of the form
   % xFRD(Model,freq,'*unit*',unit)
   ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand',FRDfcn,FRDfcn)
end
   
% Sort frequency vector, remove duplicates, and validate
freq = InputList{2};
if isnumeric(freq)
   freq = unique(freq(:));
end
freq = ltipack.utCheckFRDData(freq,'f');

% Resolve frequency units
if ni>2
   unit = ltipack.matchKey(InputList{end},{'rad/s','Hz'});
   if isempty(unit)
      ctrlMsgUtils.error('Control:ltiobject:setFRD2')
   end
else
   unit = 'rad/s';
end

% Adjust model
if isa(Model,'FRDModel')
   % Check compatibility of frequency vectors
   try
      FRDModel.mrgfreq(Model.Frequency,Model.FrequencyUnit,freq,unit);
   catch %#ok<*CTCH>
      ctrlMsgUtils.error('Control:ltiobject:frd1')
   end
elseif isa(Model,'ltipack.SingleRateSystem') && Model.Ts==-1
   % Warn about Ts=-1, see frd/checkDataConsistency for rationale
   ctrlMsgUtils.warning('Control:ltiobject:frdAmbiguousRate2')
   Model.Ts = 1;
end

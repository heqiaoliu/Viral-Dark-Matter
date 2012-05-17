function this = numericaltextfield(varargin)
%NUMERICALTEXTFIELD constructor for uicomponent numericaltextfield
%

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:47 $

this = ctrluis.numericaltextfield;

%Process input arguments
if rem(numel(varargin),2)
    ctrlMsgUtils.error('Controllib:general:CompletePropertyValuePairs','ctrluis.numericaltextfield')
end
%Look for parent argument
idx = strcmpi(varargin,'parent');
if any(idx)
   hParent = varargin{find(idx,1,'first')+1};
else
   %No parent argument put in a figure
   hParent = figure;
end
pos = [0 0 110 20];  %Default position and size

%Create javacomponent and set UDD propertes
if ~isempty(hParent)
   [h,hCont] = javacomponent('com.mathworks.toolbox.control.util.MJNumericalTextField', ...
      pos,hParent);
else
   [h,hCont] = javacomponent('com.mathworks.toolbox.control.util.MJNumericalTextField');
end
this.hJava      = h;
this.hContainer = hCont;

%Final default settings
this.hJava.setValue(sqrt(2)); %Initialize with a reasonable value

%Pass on any constructor settings
set(this,varargin{:})

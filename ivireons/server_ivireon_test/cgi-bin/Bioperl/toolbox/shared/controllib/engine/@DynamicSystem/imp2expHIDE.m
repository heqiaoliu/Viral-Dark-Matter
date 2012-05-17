function sys = imp2exp(sys,yidx,uidx)
% Metadata management for IMP2EXP

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:54 $
sys.IOSize_ = [length(yidx) length(uidx)];
InName = sys.InputName_;
if isempty(InName)
   sys.OutputName_ = [];
else
   sys.InputName_ = InName(uidx,:);
   sys.OutputName_ = InName(yidx,:);
end
InUnit = sys.InputUnit_;
if isempty(InUnit)
   sys.OutputUnit_ = [];
else
   sys.InputUnit_ = InUnit(uidx,:);
   sys.OutputUnit_ = InUnit(yidx,:);
end
InGroup = sys.InputGroup_;
if isempty(InGroup)
   sys.OutputGroup_ = struct;
else
   sys.InputGroup_ = groupref(InGroup,uidx);
   sys.OutputGroup_ = groupref(InGroup,yidx);
end
% Delete name, notes and userdata
sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];

      

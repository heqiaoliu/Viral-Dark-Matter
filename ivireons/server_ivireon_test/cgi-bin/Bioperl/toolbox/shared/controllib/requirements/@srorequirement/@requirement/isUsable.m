function bUsable = isUsable(this)
% ISUSABLE  method to check whether a requirement is usable, checks that
% the requirement is enabled, and has a source. 
%
 
% Author(s): A. Stothert 04-Aug-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:24 $

%Check requirement is enabled
bUsable = this.isEnabled;
if ~any(bUsable)
   %Quick exit as all requiremenents are disabled
   return
end

%Check for source validity
Source = this.getSource('c');
isFreq = (this.isFrequencyDomain)';
%Time domain requirement sources can only be outputs
for ct = find(~isFreq)
   if ~isempty(Source{ct}) && ishandle(Source{ct})
      bUsable(ct) = bUsable(ct) && ...
         all(strcmpi(Source{ct}.getType,'output'));
   else
      %No source defined
      bUsable(ct) = false;
   end
end
%Frequency domain requirements must have at least onen input and one output source
for ct = find(isFreq)
   if ~isempty(Source{ct}) && all(ishandle(Source{ct}))
      Types = Source{ct}.getType;
      bUsable(ct) = bUsable(ct) && ...
         any(strcmpi(Types,'output')) && ...
         any(strcmpi(Types,'input'));
   else
      %No source defined
      bUsable(ct) = false;
   end
end
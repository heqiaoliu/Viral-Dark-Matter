function sys = loadobj(s)
%LOADOBJ  Load filter for frd objects

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:52:15 $
if isa(s,'frd')
   sys = s;
else
   % Issue warning
   updatewarn
   % Upgrade
   if isfield(s,'Version_')
      % Versions 10- (MCOS)
   elseif isfield(s,'Units')
      % Versions 1-4
      sys = frd(s.ResponseData,s.Frequency,'FrequencyUnit',s.Units);
      sys = reload(sys,s.lti);
   else
      % Versions 5-9 (LTI2 - two-layer architecture)
      sys = frd;
      sys = reload(sys,s.lti);
   end
end


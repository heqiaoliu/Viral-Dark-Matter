function sys = loadobj(s)
%LOADOBJ  Load filter for tf objects

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/02/08 22:29:12 $
if isa(s,'tf')
   sys = s;
   loadver = sys.Version_;
else
   % Issue warning
   updatewarn
   % Upgrade
   if isfield(s,'Version_')
      % Versions 10- (MCOS)
   elseif isfield(s,'num')
      % Versions 1-4
      sys = tf(s.num,s.den);
      sys = reload(sys,s.lti);
      sys.Variable = s.Variable;
      loadver = s.lti.Version;
   else
      % Versions 5-9 (LTI2 - two-layer architecture)
      sys = tf;
      sys = reload(sys,s.lti);
      sys.Variable = s.Variable;
      loadver = getVersion(s.lti.dynamicsys); 
      % REVISIT: Change to s.lti.dynamicsys.Version; after deleting @dynamicsys
   end
end

% Remap q to z^-1 starting with R2009a
if loadver<9 && strcmp(sys.Variable,'q')
   sys.Variable = 'z^-1';
end

function sys = loadobj(s)
%LOADOBJ  Load filter for zpk objects

%   Author(s): G. Wolodkin
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.3.4.7 $  $Date: 2010/02/08 22:29:27 $
if isa(s,'zpk')
   sys = s;
   loadver = sys.Version_;
else
   % Issue warning
   updatewarn
   % Upgrade
   % Upgrade
   if isfield(s,'Version_')
      % Versions 10- (MCOS)
   elseif isfield(s,'z')
      % Versions 1-4
      sys = zpk(s.z,s.p,s.k);
      sys = reload(sys,s.lti);
      sys.Variable = s.Variable;
      if isfield(s,'DisplayFormat')
         % Note: DisplayFormat introduced in R13, but version was not
         % changed (remained V3)...
         sys.DisplayFormat = s.DisplayFormat;
      end
      loadver = s.lti.Version;
   else
      % Versions 5-9 (LTI2 - two-layer architecture)
      sys = zpk;
      sys = reload(sys,s.lti);
      sys.Variable = s.Variable;
      sys.DisplayFormat = s.DisplayFormat;
      loadver = getVersion(s.lti.dynamicsys); 
      % REVISIT: Change to s.lti.dynamicsys.Version; after deleting @dynamicsys
   end
end

% Remap q to z^-1 starting with R2009a
if loadver<9 && strcmp(sys.Variable,'q')
   sys.Variable = 'z^-1';
end

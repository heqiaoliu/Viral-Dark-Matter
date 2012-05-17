function s = dfprobspecdefaults(s)
%DFPROBSPECDEFAULTS Fill default entries into probability spec

%   $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:59:46 $
%   Copyright 2010 The MathWorks, Inc.

% Make sure logical fields have defaults rather than empties
testnames = {'hasconfbounds' 'iscontinuous' 'islocscale' 'uselogpp' ...
             'censoring'     'paramvec'     'optimopts'};
defaults  = {false           true           false        false      ...
             false           true           false};
for j=1:length(testnames)
   field = testnames{j};
   default = defaults{j};
   if ~isfield(s,field) || isempty(s.(field))
      val = default;
   else
      val = s.(field);
      if ~isscalar(val)
          error('stats:dfittool:WrongSize',...
                'The ''%s'' field of a distribution structure must be a scalar taking the value true or false.',...
                field);
      elseif ~(islogical(val) || isnumeric(val))
          error('stats:dfittool:NotLogical',...
                'The ''%s'' field of a distribution structure must be a scalar taking the value true or false.',...
                field);
      end
      val = (val~=0);
   end
   s.(field) = val;
end

% Check other optional fields and fill in defaults
testnames = {'code'};
defaults  = {lower(s.name)};
for j=1:length(testnames)
   field = testnames{j};
   default = defaults{j};
   if ~isfield(s,field) || isempty(s.(field))
      val = default;
   else
      val = s.(field);
      if ~isrow(val) || ~ischar(val)
          error('stats:dfittool:NotCharacter',...
                'The ''%s'' field of a distribution structure must be a character string.',...
                field);
      end
   end
   s.(field) = val;
end
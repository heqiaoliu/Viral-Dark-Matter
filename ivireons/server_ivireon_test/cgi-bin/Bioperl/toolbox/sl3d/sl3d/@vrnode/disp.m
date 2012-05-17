function disp(N)
%DISP Display a VRNODE array.
%   DISP(N) displays a VRNODE array in a standard format.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/10/16 06:45:27 $ $Author: batserve $


% print variable values
for i=1:numel(N)
  if isvalid(N(i))
    PW = get(N(i), 'World');
    fprintf('\t%s (%s) [%s]\n', getname(N(i).Name), get(N(i),'Type'), get(PW,'Description'));
  else
    fprintf('\t<invalid>\n');
  end
end

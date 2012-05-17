function disp(W)
%DISP Display a VRWORLD array.
%   DISP(W) displays a world array in a standard format.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/03/01 05:31:00 $ $Author: batserve $


% print variable values
for i=1:numel(W)
  if isvalid(W(i))
    wdf = get(W(i), {'Description', 'FileName'});
    if isempty(wdf{2})
      wdf{2} = 'No VRML File Associated';
    end
    fprintf('\t%s (%s)\n', wdf{:});
  else
    fprintf('\t<invalid>\n');
  end
end

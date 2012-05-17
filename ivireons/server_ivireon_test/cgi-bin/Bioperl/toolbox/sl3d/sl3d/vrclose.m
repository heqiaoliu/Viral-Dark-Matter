function vrclose(p)
%VRCLOSE Close virtual reality figures.
%   VRCLOSE closes all virtual reality figures.
%   VRCLOSE ALL does the same thing.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/01/19 03:06:07 $ $Author: batserve $

if nargin==0 || (ischar(p) && strcmpi(p,'all'))
  close(vrfigure(vrsfunc('GetAllFigures')));
  allfigs = getappdata(0, 'SL3D_vrfigure_List');
  if ~isempty(allfigs)
    figs = allfigs.values;
    close([figs{:}]);
  end
else
  error('VR:invalidinarg','Invalid input argument.');
end


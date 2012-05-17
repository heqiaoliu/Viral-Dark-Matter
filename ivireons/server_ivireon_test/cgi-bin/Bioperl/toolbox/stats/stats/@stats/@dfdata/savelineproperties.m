function savelineproperties(ds)
%SAVELINEPROPERTIES Save current line properties for later recovery

% $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:47 $
% Copyright 2003-2008 The MathWorks, Inc.

% Get line properties previously saved
oldcml = ds.ColorMarkerLine;

% Get line properties currently in use
lineproperties = {'Color' 'Marker' 'LineStyle' 'LineWidth'};
cml = cell(4,1);
if ~isempty(ds.line) && ishghandle(ds.line)
   cml = get(ds.line, lineproperties);
end

% Probability plots always use linestyle 'none', and other plots always
% use marker 'none', so don't write these choices over the saved ones.
if length(oldcml) >= 4
   if isequal(ds.ftype, 'probplot')
      cml(3:4) = oldcml(3:4);
   elseif ~isequal(ds.ftype, 'probplot')
      cml(2) = oldcml(2);
   end
end

% Save current properties
ds.ColorMarkerLine = cml;

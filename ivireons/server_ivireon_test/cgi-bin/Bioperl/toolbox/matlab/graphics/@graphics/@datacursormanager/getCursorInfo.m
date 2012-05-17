function [dat] = getCursorInfo(hThis)

% Copyright 2003-2005 The MathWorks, Inc.

dat = [];

hDataCursorList = get(hThis,'DataCursors');

for n = 1:length(hDataCursorList)
  h = hDataCursorList(n);
  
  % Populate structure
  hTarget = handle(get(h,'Host'));
  dat(n).Target = double(hTarget);
  hdc = get(h,'DataCursorHandle');
  dat(n).Position = get(hdc,'TargetPoint');
  if isempty(dat(n).Position)
      dat(n).Position = get(h,'Position');
  end
  
  % For now, only populate this field for lines
  % since no spec is defined for other objects.
  if isa(hTarget,'line')
     dat(n).DataIndex = get(hdc,'DataIndex');
  end
end
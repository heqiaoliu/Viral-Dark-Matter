function updateDataCursor(this,hDataCursor,target)

% Specify datatip position based on mouse click

% Copyright 2003-2008 The MathWorks, Inc.

is_horz = strcmpi(get(this,'Horizontal'),'on');

%TBD check all bar peers so mouse dragging doesn't stay 
% on the same patch
%hpeers = get(this,'BarPeers');
hpatch = get(this,'children');
[p,v,ind,pfactor,barface] = vertexpicker(hpatch,target,'-force');

% Specify index into bar series
origInd = ind;
ind = floor((ind-1)/5)+1; % 4 patch vertices for each bar
len = length(this.xdata);
if ind>len,
    ind = len;
elseif ind==0
    ind = 1;
end

% Specify bar face if we are mouse dragging off the bar plot
if isempty(barface)
   faces = get(hpatch,'Faces');
   verts = get(hpatch,'Vertices');
   [m,unused] = find(faces==origInd);
   if ~isempty(m)
      barface = verts(faces(m(1),:),:)';
   else % If we still can't find a face, take the first indexed face.
       barface = verts(faces(ind,:),:)';
   end
end

% Specify cursor position
if ~isempty(barface)
   x_max = max(barface(1,:));
   x_min = min(barface(1,:));
   y_max = max(barface(2,:));
   y_min = min(barface(2,:));
   if is_horz
       % We need to figure out which end is further from the baseline
       % (This will either be the min or max)
       loc = [x_min x_max];
       [unused locInd] = max(abs(loc - this.BaseValue));
       set(hDataCursor,'Position',[loc(locInd), (y_min+y_max)/2, 0]);
   else
       loc = [y_min y_max];
       [unused locInd] = max(abs(loc - this.BaseValue));      
       set(hDataCursor,'Position',[(x_max+x_min)/2, loc(locInd), 0]);
   end
   set(hDataCursor,'DataIndex',ind);
   pos = hDataCursor.Position;
   set(hDataCursor,'TargetPoint',[pos(1) pos(2)]);
end
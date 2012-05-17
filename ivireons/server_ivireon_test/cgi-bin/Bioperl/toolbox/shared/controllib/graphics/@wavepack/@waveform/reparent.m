function reparent(this,Axes)
%REPARENT  Remaps @waveform to new HG axes grid.
 
%  Author(s): Bora Eryilmaz
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:05 $

if nargin<2
   % Get current curve->axes map
   Axes = getaxes(this);  % size = [Ny Nu nr nc] where [nr nc]=subplot size
else
   % Passing full axes grid -> take row and column indices into account
   Axes = Axes(this.RowIndex,this.ColumnIndex,:,:);
end
nax = numel(Axes);
if nax==0
   % g138403
   return
end


% Reparent Waveform groups
if ~isempty(this.Group) 
    for ct = 1:nax
        set(this.Group(ct),'Parent',Axes(ct))
    end
    % don't change legend behavior for siminputs
    if ~isa(this,'resppack.siminput')
        [unax,unidx] = unique(Axes(:));
        validGroups = this.Group(unidx);

        % Set legend behaviors
        for ct =1:length(validGroups)
            hasbehavior(validGroups(ct),'legend',true)
        end

        invalidGroups = this.Group(setxor(1:length(this.Group),unidx));
        for ct =1:length(invalidGroups)
            hasbehavior(invalidGroups(ct),'legend',false)
        end
    end
end

% Reparent @waveform's view objects (@view instances)
% REVISIT: ::reparent(this,Axes)
for vct = 1:length(this.View)
   viewHandles  = ghandles(this.View(vct));  
   % viewHandles has size [Ny Nu nr nc nobj] or [Ny Nu nobj] if nr*nc=1
   nobj = numel(viewHandles)/nax;
   viewHandles  = reshape(viewHandles,nax,nobj);
   for ct=1:nax
      isValid = ishandle(viewHandles(ct,:));
      % Parent to the valid waveform group for Axes(ct)    
      set(viewHandles(ct,isValid),'Parent',this.Group(ct))
   end
end

% Reparent characteristics objects
for c = this.Characteristics'
   reparent(c,Axes);
end

curaxes = get(ancestor(Axes(1),'figure'),'CurrentAxes');
if isempty(curaxes) || ~any(double(curaxes) == double(Axes(:)))
    set(ancestor(Axes(1),'figure'),'CurrentAxes',Axes(1))
end
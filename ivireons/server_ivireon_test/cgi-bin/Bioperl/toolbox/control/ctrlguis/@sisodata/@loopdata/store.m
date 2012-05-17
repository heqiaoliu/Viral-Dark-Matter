function store(this,Name)
% Stores designs in design history.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2005/12/22 17:40:22 $
CurrentDesign = exportdesign(this);
CurrentDesign.Name = Name;

% Tag each component with the "store" name
fNames = CurrentDesign.Fixed;
for ct=1:length(fNames)
   CurrentDesign.(fNames{ct}).Name = sprintf('%s_%s',Name,fNames{ct});
end
tNames = CurrentDesign.Tuned;
for ct=1:length(tNames)
   CurrentDesign.(tNames{ct}).Name = sprintf('%s_%s',Name,tNames{ct});
end

% Update design history
ind = find(strcmpi(Name,get(this.History,{'Name'})));
if isempty(ind)
    this.History = [this.History; CurrentDesign];
else
    this.History = ...
       [this.History(1:ind-1); CurrentDesign; this.History(ind+1:end)];
end

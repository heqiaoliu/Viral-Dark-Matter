function newName = generateUniqueModelName(Type,ProposedName)
% generate a unique name for the model of chosen type (class), beginning
% from the proposed name.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/06/13 15:21:56 $

% get all model names of specified type
allNames =  nlutilspack.getAllModels(Type,true);
if nargin<2
    ProposedName = '';
end
    
if ~isempty(ProposedName) && ~ismember(ProposedName,allNames)
    newName = ProposedName;
    return;
end

if isempty(ProposedName)
    if strcmpi(Type,'idnlarx')
        Name = 'nlarx';
    elseif strcmpi(Type,'idnlhw')
        Name = 'nlhw';
    else
        Name = Type;
    end
    newName = [Name,'1'];
    k = 1;
else
    Name = ProposedName;
    K = str2double(Name(end));
    if ~isnan(K)
        newName = [Name(1:end-1),num2str(K+1)]; 
        k = K;
    else
        newName = [Name,'1'];
        k = 1;
    end
end

while ismember(newName,allNames) 
     k = k+1;
     newName = sprintf('%s%d',newName(1:end-1),k);
end

function m = getMessengerInstance(id)
%return a unique messenger instance used by GUI. In future, when we could
%have multiple identification tasks, messenger would not be a singleton.
%There will be one instance for each task, identified by its ID.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:24 $

mlock
persistent ActiveSystemIdMessengersArray;

m = [];
Flag = false;

if nargin<1
    id = 'OldSITBGUI';
end

if ~isempty(ActiveSystemIdMessengersArray)
    [Flag,Ind] = ismember(id,get(ActiveSystemIdMessengersArray,{'MessengerID'}));
end

if Flag
    % messenger instance found
    m =  ActiveSystemIdMessengersArray(Ind);
else
    m = nlutilspack.messenger;
    ActiveSystemIdMessengersArray = [ActiveSystemIdMessengersArray;m];
end

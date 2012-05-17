function editadditionalparameters(h)
%EDITADDITIONALPARAMETERS Allows access to the additional parameters

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2005/06/16 08:45:28 $

% Find all properties with a description
[props, descs] = getbuttonprops(h);

% Get default answers
answers = get(h, props);
if ~isa(answers, 'cell')
    answers = {answers};
end

% Build an input dialog out of the additional parameters
newvals = inputdlg(descs, 'Set Additional Parameters', ...
    1, answers);

% If newvals is empty, the user pressed cancel, don't change value
if ~isempty(newvals),
    
    if ~iscell(props),
        props = {props};
    end
    
    c = {props{:}; newvals{:}};
    set(h, c{:});
    
    % Send a modified event
    send(h, 'UserModifiedSpecs', handle.EventData(h, 'UserModifiedSpecs'));
end

% [EOF]

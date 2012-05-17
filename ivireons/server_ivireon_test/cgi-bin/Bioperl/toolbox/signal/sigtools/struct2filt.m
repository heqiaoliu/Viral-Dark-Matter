function Hd = struct2filt(s)
%STRUCT2FILT   Convert the structure representation back to the filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:11:39 $

% Special case the multistage case.
if isfield(s, 'Stage1')
    
    % Loop over each stage and call struct2filt to get the filter.
    for indx = 1:length(fieldnames(s))-1
        Hdstage(indx) = struct2filt(s.(sprintf('Stage%d', indx)));
    end
    
    % Build the multistage from the stages.
    Hd = feval(s.class, Hdstage);
else
    
    % Construct the new object.
    Hd = feval(s.class);
    
    % Set its properties.
    set(Hd, rmfield(s, 'class'));
end

% [EOF]

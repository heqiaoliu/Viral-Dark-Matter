function name = getname(hObj, name)
%GETNAME Update the title on the tworesps axes

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:30:14 $

if isempty(hObj.Analyses), return; end

t1 = get(hObj.Analyses(1), 'Name');
t2 = get(hObj.Analyses(2), 'Name');

indx = findstr(t1, ' Response');

if ~isempty(indx),
    
    % Only remove 'Response' if both of the objects try to display it.
    jndx = findstr(t2, ' Response');
    if ~isempty(jndx),
        t1(indx:indx+8) = [];
        
        % If there is anything after 'Response' move it before response.
        % This will let us move the dB from after response to before.
        % Phase and Magnitude (dB) Analyses
        % instead of:
        % Phase and Magnitude Analyses (dB)
        xtra = deblank(t2(jndx+10:end));
        if ~isempty(xtra), xtra = [' ' xtra]; end
        t2 = [deblank(t2(1:jndx)) xtra ' Responses' ];
    end
end

name = sprintf('%s and %s', xlate(t1), xlate(t2));

% [EOF]

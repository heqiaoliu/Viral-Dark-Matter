function showfixptsimranges(action, model)
%SHOWFIXPTSIMRANGES show min/max/overflow logs from the last simulation of
%a model. 

% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.1.4.2 $  
% $Date: 2008/08/26 18:27:45 $

if nargin < 2
    model = bdroot;
end
if isempty(model)
    return;
end

if nargin < 1
    action = 'verbose';
else
    global FixPtSimRanges; %#ok<TLEV>
end

if isempty(strcmp(action, {'verbose','quiet'}))
    DAStudio.Error('SimulinkFixedPoint:autoscaling:actionNotSupport');
end
    
    
FixPtSimRanges = retrievefixptsimranges(model, 0);

if strcmp(action, 'verbose')
    for i = 1:length(FixPtSimRanges)
        disp(' ')
        disp(FixPtSimRanges{i})
    end
end

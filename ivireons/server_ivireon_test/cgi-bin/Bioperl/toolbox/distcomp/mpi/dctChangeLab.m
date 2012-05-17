function dctChangeLab(inStr)
; %#ok undocumented

% tell the callback to switch current lab
% private function

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:07:21 $

% prevents labchange box from changing the lab when the selected lab is
% zero like in the default page.
profilerstate = com.mathworks.mde.profiler.Profiler.getSelectedLabsFromHtml;
if profilerstate(1)==0
    return;
end

dctMpiProfHelpers('changelab', 0, inStr);

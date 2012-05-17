function [F, A] = getmask(this, fcns, rcf, specs)
%GETMASK   Get the mask.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:22:46 $

if nargin < 4 || isempty(specs)
    specs = getspecs(this);
end

F = [0 specs.Fpass1 specs.Fpass1 specs.Fpass2 specs.Fpass2 1 ...
    NaN 0 specs.Fstop1 specs.Fstop1 specs.Fstop2 specs.Fstop2 1]*fcns.getfs()/2;

astop1 = fcns.formatastop(specs.Astop1);
astop2 = fcns.formatastop(specs.Astop2);

apass = fcns.formatapass(specs.Apass);

A = [astop1(1:2) apass(1) apass(1) astop2(2) astop2(1) NaN ...
    astop1(4) astop1(3) apass(2) apass(2) astop2(3:4)];

% % When the Fpass and Fstop frequency points are the same, add a NaN to keep
% % the line from doubling back on top of itself, which causes the dashes to
% % line up and "thicken" the line.
% if specs.Fpass1 == specs.Fstop1 && ~isnan(A(2))
%     A = [A(1:2) NaN A(3:end)];
%     F = [F(1:2) NaN F(3:end)];
% end
% 
% if specs.Fpass2 == specs.Fstop2 && ~isnan(A(5))
%     A(4) = NaN;
% end

% % If the passband ripple is "0" then we only want one line going across the
% % passband for the same reason as above.
% if apass(1) == 0 && apass(2) == 0
%     A = [A(1:9) nan A(10:end)];
%     F = [F(1:9) nan F(10:end)];
% end

% [EOF]

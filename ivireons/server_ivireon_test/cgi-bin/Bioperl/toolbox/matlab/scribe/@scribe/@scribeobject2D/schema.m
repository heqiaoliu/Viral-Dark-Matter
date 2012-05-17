function schema
%SCHEMA defines the abstract class for all 2-D scribe objects.
%

%   Copyright 2006 The MathWorks, Inc. 
%   $  $  $

pkg   = findpackage('scribe'); % Scribe package
% All 1-D scribe objects inherit from the abstract scribe class
cls = schema.class(pkg, 'scribeobject2D', pkg.findclass('scribeobject'));

p = schema.prop(cls,'PinPosition','real point');
p.AccessFlags.Init = 'on';
p.AccessFlags.Serialize = 'on';
p.FactoryValue = [0 0];
p.Visible = 'off';
p.SetFunction = @localSetPinPosition;
p.GetFunction = @localGetPinPosition;

%---------------------------------------------------------------------%
function valueStored = localSetPinPosition(hThis, valueProposed)
% Sets the position of the pin by finding the affordance closest to the
% proposed point.

% If the pin does not exist, the value is stored without any checks for
% validity. Otherwise, find the closest affordance and pin the annotation
% to that affordance.
if isempty(hThis.PinExists) || ~hThis.PinExists
    valueStored = valueProposed;
else
    % First, convert into figure normalized units
    pinPos = valueProposed;
    hFig = ancestor(hThis,'Figure');
    normPos = hgconvertunits(hFig,hThis.Position,hThis.Units,'normalized',hFig);
    pinPos = pinPos .* normPos(3:4) + normPos(1:2);
    % Find the affordance nearest to the location and pin the affordance
    affNum = localFindAffordance(hThis,pinPos);
    hThis.pinAtAffordance(affNum);
end

%---------------------------------------------------------------------%
function valueToCaller = localGetPinPosition(hThis, valueStored) %#ok
% Returns the position of the pin in units normalized with respect to the
% annotation.

% If the pin does not exist, return [0 0]. Otherwise, return the position
% of the affordance in units which are normalized with respect to the
% annotation.
if isempty(hThis.PinExists) || ~hThis.PinExists
    valueToCaller = [0 0];
else
    hPin = hThis.Pin;
    pinPos = [hPin.XData hPin.YData];
    hFig = ancestor(hThis,'Figure');
    normPos = hgconvertunits(hFig,hThis.Position,hThis.Units,'normalized',hFig);
    valueToCaller = (pinPos - normPos(1:2)) ./ normPos(3:4);
end

%---------------------------------------------------------------------%
function affNum = localFindAffordance(hThis, point)
% Given a point in normalized units, find the nearest affordance

% Get the affordance locations
hAff = hThis.Srect;
affXData = cell2mat(get(hAff,'XData'));
affYData = cell2mat(get(hAff,'YData'));
% Compute the Euclidean distance:
affSquareX = (affXData - point(1)).^2;
affSquareY = (affYData - point(2)).^2;
affDist = sqrt(affSquareX + affSquareY);
% Now, find the minimum
[unused, affNum] = min(affDist);
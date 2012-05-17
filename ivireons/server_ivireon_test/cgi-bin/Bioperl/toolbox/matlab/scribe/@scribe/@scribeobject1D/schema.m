function schema
%SCHEMA defines the abstract class for all 1-D scribe objects.
%

%   Copyright 2006 The MathWorks, Inc. 
%   $  $  $

pkg   = findpackage('scribe'); % Scribe package
% All 1-D scribe objects inherit from the abstract scribe class
cls = schema.class(pkg, 'scribeobject1D', pkg.findclass('scribeobject'));

% Rather than having a "Position" property, 1-D objects contain "X" and
% "Y" properties. In this implementation, we will define these as
% pass-through properties to the underlying "Position" property.
p = schema.prop(cls,'X','NReals');
p.SetFunction = @localSetX;
p.GetFunction = @localGetX;
% These numbers come from the existing scribe defaults
p.FactoryValue = [0.3 0.4];

p = schema.prop(cls,'Y','NReals');
p.SetFunction = @localSetY;
p.GetFunction = @localGetY;
% These numbers come from the existing scribe defaults
p.FactoryValue = [0.3 0.4];

% Objects will need access to the normalized units at all times. Supply
% internal properties for this:
p = schema.prop(cls,'NormX','NReals');
p.GetFunction = @localGetNormX;
% These numbers come from the existing scribe defaults
p.FactoryValue = [0.3 0.4];
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PrivateSet = 'off';

p = schema.prop(cls,'NormY','NReals');
p.GetFunction = @localGetNormY;
% These numbers come from the existing scribe defaults
p.FactoryValue = [0.3 0.4];
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PrivateSet = 'off';

%--------------------------------------------------------------------%
function valueToCaller = localGetNormY(hThis,valueStored) %#ok
% The "Y" property translates to the bottom coordinate and the left
% coordinate plus the height:

pos = hThis.Position;
hFig = ancestor(hThis,'Figure');
% Convert to normalized units:
pos = hgconvertunits(hFig,pos,hThis.Units,'Normalized',hFig);

valueToCaller = [pos(2) pos(2)+pos(4)];

%--------------------------------------------------------------------%
function valueToCaller = localGetNormX(hThis,valueStored) %#ok
% The "X" property translates to the left coordinate and the left
% coordinate plus the width:

pos = hThis.Position;
hFig = ancestor(hThis,'Figure');
% Convert to normalized units:
pos = hgconvertunits(hFig,pos,hThis.Units,'Normalized',hFig);

valueToCaller = [pos(1) pos(1)+pos(3)];

%--------------------------------------------------------------------%
function valueStored = localSetX(hThis,valueProposed)
% The "X" property translates to the left coordinate and the left
% coordinate plus the width:

if numel(valueProposed) ~= 2
    error('MATLAB:annotation:invalidinput','Value must be a 2-element vector');
end
valueStored = valueProposed;
% Update the position accordingly.
pos = hThis.Position;
pos(1) = valueProposed(1);
pos(3) = valueProposed(2)-valueProposed(1);
hThis.Position = pos;

%--------------------------------------------------------------------%
function valueToCaller = localGetX(hThis,valueStored) %#ok
% The "X" property translates to the left coordinate and the left
% coordinate plus the width:

pos = hThis.Position;
valueToCaller = [pos(1) pos(1)+pos(3)];

%--------------------------------------------------------------------%
function valueStored = localSetY(hThis,valueProposed)
% The "Y" property translates to the bottom coordinate and the left
% coordinate plus the height in normalized coordinates:

if numel(valueProposed) ~= 2
    error('MATLAB:annotation:invalidinput','Value must be a 2-element vector');
end
valueStored = valueProposed;
% Update the position accordingly.
pos = hThis.Position;
pos(2) = valueProposed(1);
pos(4) = valueProposed(2)-valueProposed(1);
hThis.Position = pos;

%--------------------------------------------------------------------%
function valueToCaller = localGetY(hThis,valueStored) %#ok
% The "Y" property translates to the bottom coordinate and the left
% coordinate plus the height:

pos = hThis.Position;

valueToCaller = [pos(2) pos(2)+pos(4)];
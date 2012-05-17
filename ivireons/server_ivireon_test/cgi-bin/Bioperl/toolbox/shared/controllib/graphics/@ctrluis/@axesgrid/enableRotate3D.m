function enableRotate3D(this)
%ENABLEROTATE3D  Enable Rotate3D behavior property for axes in Axesgrid

%  Author(s): C. Buhr
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:14:56 $

% Enable Rotation for axes
bh = hgbehaviorfactory('Rotate3D');
set(bh,'Enable',true);
hgaddbehavior(this.Axes2d(:),bh);
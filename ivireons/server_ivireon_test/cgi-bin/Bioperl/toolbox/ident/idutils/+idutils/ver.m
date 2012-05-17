function InstalledVersion = ver()
%VER  Returns installed version of all SITB objects.
%     Used in loadobj and constructor of all objects.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/12/05 02:04:19 $

% R2008a: Introduce new algorithm properties - Weighting and Criterion
% Also, remove 'GNS' from idmodel's Algorithm.

% R2008b: Renamed Algorithm property "Trace" to "Display".

% R2010a: Added idpoly.BFFormat (ver 4)

InstalledVersion = 4;  

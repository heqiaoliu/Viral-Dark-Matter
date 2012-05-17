function hIT = import
%IMPORT The constructor for the Import Tool
%   IMPORT(hFig, hTARGET)

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 23:29:38 $

% Instantiate the object
hIT = siggui.import;

% Set up the Structure % Coefficient object
addcomponent(hIT, siggui.coeffspecifier);

% Create the Sampling Frequency object
addcomponent(hIT, siggui.fsspecifier);

% Set up the flags
set(hIT,'isImported',0);
set(hIT,'Version',1);

% [EOF]

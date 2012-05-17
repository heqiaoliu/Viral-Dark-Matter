function out=openprj(filename)
%OPENPRJ opens a deployment project file in DEPLOYTOOL.
%
%   OPENPRJ(FILENAME) opens the deployment project file, FILENAME, 
%   in the Deployment Tool GUI. 
%
%   See also DEPLOYTOOL, MCC, MBUILD.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/10/14 12:20:20 $

out=[];
deploytool(filename);
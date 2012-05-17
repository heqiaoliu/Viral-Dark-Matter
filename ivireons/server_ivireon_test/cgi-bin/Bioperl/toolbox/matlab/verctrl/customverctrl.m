function customverctrl(fileNames, arguments)
%CUSTOMVERCTRL Custom version control template.
%   CUSTOMVERCTRL(FILENAMES, ARGUMENTS) is supplied as a function
%   stub for customers who want to integrate a version control
%   system that is not supported by MathWorks.
%
%   This function must conform to the structure of one of the
%   supported version control systems, e.g., RCS.  See rcs.m as
%   an example.
%   
%   See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, RCS, SOURCESAFE,
%   PVCS, and CLEARCASE.
%

%   Copyright 1998-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2009/12/14 22:25:59 $

% Remove this error message when integrating a custom version
% control system:
error('MATLAB:sourceControl:noCustomSystem','No custom source control system has been configured.');

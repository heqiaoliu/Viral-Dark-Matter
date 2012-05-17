function [strs,absstatus] = tsgetDateFormat
%
% tstool utility function

%TSISDATEFORMAT Utility to detect if a string is a valid data format
%
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2006/06/27 23:05:41 $

datestrs = {'dd-mmm-yyyy HH:MM:SS',true;
'dd-mmm-yyyy',true;
'mm/dd/yy',true;     
'HH:MM:SS',false;    
'HH:MM:SS PM',false;
'HH:MM',false;     
'HH:MM PM',false;           
'mmm.dd,yyyy HH:MM:SS',true;
'mmm.dd,yyyy',true;
'mm/dd/yyyy',true};

strs = datestrs(:,1);
absstatus = datestrs(:,2);

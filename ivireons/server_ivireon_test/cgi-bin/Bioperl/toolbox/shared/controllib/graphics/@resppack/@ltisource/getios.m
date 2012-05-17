function [inames,onames] = getios(src)
%GETIOS  Returns input and output names.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:19 $
inames = src.Model.InputName;
onames = src.Model.OutputName;

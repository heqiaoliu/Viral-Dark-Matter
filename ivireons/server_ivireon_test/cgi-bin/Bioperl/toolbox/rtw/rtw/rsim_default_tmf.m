function [tmf,envVal, mexOpts] = rsim_default_tmf
%GRT_DEFAULT_TMF Returns the "default" template makefile for use with rsim.tlc
%
%       See get_tmf_for_target in the toolbox/rtw/private directory for more 
%       information.

%       Copyright 1994-2010 The MathWorks, Inc.
%       $Revision: 1.9.66.1 $

[tmf,envVal, mexOpts] = get_tmf_for_target('rsim');

%end rsim_default_tmf.m

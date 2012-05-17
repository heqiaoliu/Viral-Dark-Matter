function [tmf,envVal, mexOpts] = grt_malloc_default_tmf
%GRT_MALLOC_DEFAULT_TMF Returns the "default" template makefile for use with 
%grt_malloc.tlc
%
%       See get_tmf_for_target in the toolbox/rtw/private directory for more 
%       information.

%       Copyright 1994-2010 The MathWorks, Inc.
%       $Revision: 1.9.66.1 $

[tmf,envVal, mexOpts] = get_tmf_for_target('grt_malloc');

%end grt_malloc_default_tmf.m

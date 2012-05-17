function extrinsic(varargin)
%EML.EXTRINSIC Declare a function to be extrinsic and instruct Embedded MATLAB not to compile it. 
% 
%  Usage:
% 
%  EML.EXTRINSIC('FCN') 
%    Declares the function FCN to be extrinsic.
% 
%  EML.EXTRINSIC('FCN1',...,'FCNn') 
%    Declares the functions FCN1 through FCNn to be extrinsic.
% 
%  EML.EXTRINSIC('-sync:on','FCN') 
%  EML.EXTRINSIC('-sync:on','FCN1',...,'FCNn') 
%    Declares the function FCN or functions FCN1 through FCNn to be extrinsic,
%    and enables synchronization of global variables whenever these functions  
%    are called.
% 
%  EML.EXTRINSIC('-sync:off','FCN') 
%  EML.EXTRINSIC('-sync:off','FCN1',...,'FCNn') 
%    Declares the function FCN or functions FCN1 through FCNn to be extrinsic,
%    and disables synchronization of global variables whenever these functions
%    are called.
% 
%  During simulation, Embedded MATLAB transfers control to MATLAB which 
%  resolves and executes extrinsic functions. 
%  While generating code for embedded targets, Embedded MATLAB ignores 
%  calls to extrinsic functions, provided they do not affect execution 
%  of the host function; otherwise, Embedded MATLAB issues compilation errors. 
%
%  This function has no effect in MATLAB; it applies to Embedded MATLAB only.

%   Copyright 2006-2010 The MathWorks, Inc.


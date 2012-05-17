%cgv.CGV.addCallback
% 
% Add callback function
%
% Syntax:
%   cgvObj.addCallback(CallbackFcn)
%
% Description:
%   Adds a callback function.  The object calls the callback function for each set of
%   input data that you provide, before executing the model.  
%   Note: This method has no effect after calling the run method.
%   
% Inputs:
%   The declaration of the callback function must receive the following parameters:
%     CallbackFcn(inputIndex, ModelName, componentType, connectivity) 
%   ModelName, componentType, and connectivity are identical to the arguments that you
%   specify in the cgvObj constructor. InputIndex is the unique identifier of the input
%   data that the callback function executes.
%

 
% Copyright 2000-2009 The MathWorks, Inc.


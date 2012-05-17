%cgv.CGV.run()
% 
% Execute CGV object
%
% Syntax:
%   result = cgvObj.run()
%
% Description:
%   The object checks whether the model is configured correctly, then executes the model
%   once for each input data that you added to the object. After each execution of the
%   model, the object captures and writes metadata to a file in the output folder.
%
% Notes: 
%   • Configure the object before calling run. Do at least one call to addInputData. The
%     object ignores all calls to methods after you call run.
%   • Only call run once for each object.
%   
% Outputs:
%   Returns a boolean value that indicates whether the run completed without execution error.

 
% Copyright 2000-2009 The MathWorks, Inc.


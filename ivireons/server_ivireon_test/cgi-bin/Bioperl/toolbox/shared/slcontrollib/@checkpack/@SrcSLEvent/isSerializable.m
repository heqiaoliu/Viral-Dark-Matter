function b = isSerializable(this) %#ok<INUSD>
%ISSERIALIZABLE True if the object is Serializable. 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:07 $

% The WiredSource extension is not serializable because it's Configuration
% (sources tab) should not be changed. One should not be able to save the
% configuration (sources tab) to the model file nor should you be able to
% load the source configuration (sources tab) from a model. Changing the
% Sources tab can cause conflicts with how the Wired source extension
% behaves and should be avoided.
    
b = false;
end

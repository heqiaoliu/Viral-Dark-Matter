%AUTOTRANSFER - automatically transfers the value out of the SPMD block

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/12/29 01:56:49 $

classdef AutoTransfer
    properties
        Lab
        Value
    end
    
    methods
        function obj = AutoTransfer( value, opt_lab )
            if nargin == 1
                obj.Lab = 1;
            else
                obj.Lab = opt_lab;
            end
            if labindex == obj.Lab
                obj.Value = value;
            else
                obj.Value = [];
            end
        end
        
        function [factory, userData] = getRemoteFromSPMD( obj )
            userData = {obj.Value, obj.Lab};
            factory = @iBuildAutoDeref;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build the autoderef. userDataCell is a cell array of all the user datas,
% each of which is a 2-element cell array.
function remote = iBuildAutoDeref( userDataCell )
ud1 = userDataCell{1};
labWithData = ud1{2};
remote = distributedutil.AutoDeref( userDataCell{labWithData}{1} );
end

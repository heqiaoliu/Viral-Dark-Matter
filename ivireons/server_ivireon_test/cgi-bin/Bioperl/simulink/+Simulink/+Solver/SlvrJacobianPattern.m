classdef SlvrJacobianPattern
% Simulink.Solver.SlvrJacobianPattern - Contains information related to solver 
% Jacobian pattern.
% 
% A Simulink.Solver.SlvrJacobianPattern has the following fields:
%
%         Jpattern :  a mxArray of sparse pattern
%      numColGroup :  number of column groups of the sparse matrix
%         colGroup :  A double vector of each column's group number
%       stateNames :  A cell array contains the name of each states
%     blockHandles:   A double array of all the block handles of each block that
%                     has continuous states 
%    
%     the show method will display the Jacobian pattern in a figure. 
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ 
    
    properties
        Jpattern
        numColGroup
        colGroup
        stateNames
        blockHandles
    end
    
    methods
        function JpObj = SlvrJacobianPattern(JpStructIn)
            if(isfield(JpStructIn,'Jpattern'))                              
                JpObj.Jpattern = JpStructIn.Jpattern;
            end
            
            if(isfield(JpStructIn,'numColGroup'))                              
                JpObj.numColGroup = JpStructIn.numColGroup;
            end
            
            if(isfield(JpStructIn,'colGroup'))                              
                JpObj.colGroup = JpStructIn.colGroup;
            end
            
            if(isfield(JpStructIn,'stateNames'))                              
                JpObj.stateNames = JpStructIn.stateNames;
            end
            
            if(isfield(JpStructIn,'blockHandles'))                              
                JpObj.blockHandles = JpStructIn.blockHandles;
            end
        end        
        
        function show(JpObj)
        % Show the solver sparsity pattern with a figure                        
            nz = length(find(JpObj.Jpattern));            
            nx = length(JpObj.Jpattern);              
            axis([0 nx+0.5 0 nx+0.5]) ;
            spy(JpObj.Jpattern);
            title(['Sparsity pattern:   ', 'nz =', num2str(nz)]);
            xlabel('x');
            ylabel('$\dot{x}$', 'Interpreter', 'latex', 'Rotation', 0);
            set(gca, 'XTick', 1:nx);
            set(gca, 'YTick', 1:nx);           
           
        end                
    end
end


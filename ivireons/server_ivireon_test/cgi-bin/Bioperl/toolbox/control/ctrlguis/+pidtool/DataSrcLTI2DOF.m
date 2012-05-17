classdef DataSrcLTI2DOF < pidtool.DataSrcLTI
    % DATASRCLTI subclass
    %
    
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.5 $ $Date: 2010/05/10 16:58:44 $
 
     methods(Access = 'public')

        % constructor
        function this = DataSrcLTI2DOF(G,Type,Baseline)
            this = this@pidtool.DataSrcLTI(G,Type,Baseline);
            this.DOF = 2;
        end
        
        % helper function used by plot panel
        function Data = initialParameterTableData(this)
            tmp = blanks(4);
            if strcmp(this.Form,'parallel');
                switch this.Type
                    case 'pi'
                        Data = {'Kp',tmp,tmp;'Ki',tmp,tmp;'b',tmp,tmp};
                    case 'pd'
                        Data = {'Kp',tmp,tmp;'Kd',tmp,tmp;'c',tmp,tmp};
                    case 'pdf'
                        Data = {'Kp',tmp,tmp;'Kd',tmp,tmp;'Tf',tmp,tmp;'c',tmp,tmp};
                    case 'pid'
                        Data = {'Kp',tmp,tmp;'Ki',tmp,tmp;'Kd',tmp,tmp;'b',tmp,tmp;'c',tmp,tmp};
                    case 'pidf'
                        Data = {'Kp',tmp,tmp;'Ki',tmp,tmp;'Kd',tmp,tmp;'Tf',tmp,tmp;'b',tmp,tmp;'c',tmp,tmp};
                end
            else
                switch this.Type
                    case 'pi'
                        Data = {'Kp',tmp,tmp;'Ti',tmp,tmp;'b',tmp,tmp};
                    case 'pd'
                        Data = {'Kp',tmp,tmp;'Td',tmp,tmp;'c',tmp,tmp};
                    case 'pdf'
                        Data = {'Kp',tmp,tmp;'Td',tmp,tmp;'N',tmp,tmp;'c',tmp,tmp};
                    case 'pid'
                        Data = {'Kp',tmp,tmp;'Ti',tmp,tmp;'Td',tmp,tmp;'b',tmp,tmp;'c',tmp,tmp};
                    case 'pidf'
                        Data = {'Kp',tmp,tmp;'Ti',tmp,tmp;'Td',tmp,tmp;'N',tmp,tmp;'b',tmp,tmp;'c',tmp,tmp};
                end
            end
        end
        
     end
    
end

classdef DataSrcBlk2DOF < slctrlguis.pidtuner.DataSrcBlk
    % DATASRCBLK2DOF subclass
    %
    
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.7 $ $Date: 2010/03/26 17:53:48 $
 
    %Public constructor
    methods(Access = 'public')

        % constructor
        function this = DataSrcBlk2DOF(GCBH,G)
            this = this@slctrlguis.pidtuner.DataSrcBlk(GCBH,G);
            this.DOF = 2;
        end
        
        % update PID and loop data based on PID gains from block
        function setBaseline(this)
            setBaseline@slctrlguis.pidtuner.DataSrcBlk(this);
            this.generateFilterForBlock;
        end
        
        % update PID gains and loop data based on Cfb
        function setTunedController(this)
            setTunedController@slctrlguis.pidtuner.DataSrcBlk(this);
            this.generateFilterForTuned;
        end
        
        % helper function used by plot panel
        function Data = initialParameterTableData(this) %#ok<*MANU>
            Data = cell(6,3);
            Data(:)={blanks(4)};
            Data(1,1) = {'P'};
            Data(2,1) = {'I'};
            Data(3,1) = {'D'};
            Data(4,1) = {'N'};
            Data(5,1) = {'b'};
            Data(6,1) = {'c'};
        end
        
    end
    
    methods(Access = 'protected')
        
        function generateFilterForTuned(this)
            [~,~,Cff] = utPID1dof_getCfreeCfixedfromPIDN(this.P*(1-this.b),0,this.D*(1-this.c),this.N,this.SampleTime,this.getCtrlStruct);
            Cff.InputName = 'r';  
            Cff.OutputName = 'uff';
            this.Cff = Cff;
            Sum1 = sumblk('u','ufb','uff','+-');
            Sum2 = sumblk('e','r','y','+-');
            this.r2y = connect(this.G2,this.Cfb,this.Cff,Sum1,Sum2,'r','y');
            this.r2u = connect(this.G2,this.Cfb,this.Cff,Sum1,Sum2,'r','u');
        end
        
        function generateFilterForBlock(this)
            [~,~,Cff_Blk] = utPID1dof_getCfreeCfixedfromPIDN(this.P_Blk*(1-this.b_Blk),0,this.D_Blk*(1-this.c_Blk),this.N_Blk,this.SampleTime,this.getCtrlStruct);
            Cff_Blk.InputName = 'r';  
            Cff_Blk.OutputName = 'uff';
            this.Cff_Blk = Cff_Blk;
            Sum1 = sumblk('u','ufb','uff','+-');
            Sum2 = sumblk('e','r','y','+-');
            this.r2y_Blk = connect(this.G2,this.Cfb_Blk,this.Cff_Blk,Sum1,Sum2,'r','y');
            this.r2u_Blk = connect(this.G2,this.Cfb_Blk,this.Cff_Blk,Sum1,Sum2,'r','u');
        end
        
    end
    
end

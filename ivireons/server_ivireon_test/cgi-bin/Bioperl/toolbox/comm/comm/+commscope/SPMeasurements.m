classdef SPMeasurements < hgsetget & sigutils.sorteddisp
    %SPMeasurements Construct a scatter plot measurements manager object
    
    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $  $Date: 2008/12/04 22:16:30 $

    %===========================================================================
    % Public Observable properties
    properties (SetObservable)
        Percentile = 95;
    end
    
    %===========================================================================
    % Read-only Dependent properties
    properties (SetAccess = private, Dependent)
        RMSEVM;
        MaximumEVM;
        PercentileEVM;
        MERdB;
        MinimumMER;
        PercentileMER;
    end
    
    %===========================================================================
    % Private properties
    properties (Access = private)
        EVM;
        MER;
    end
    
    %===========================================================================
    % Public Hidden methods
    methods (Hidden)
        function this = SPMeasurements
            this.EVM = commmeasure.EVM('Percentile', this.Percentile);
            this.MER = commmeasure.MER('Percentile', this.Percentile);
        end
        %-----------------------------------------------------------------------
        function reset(this)
            reset(this.EVM);
            reset(this.MER);
        end
        %-----------------------------------------------------------------------
        function update(this, y, x)
            update(this.EVM, y, x)
            update(this.MER, y, x)
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function v = get.RMSEVM(this)
            v = this.EVM.RMSEVM;
        end
        %-----------------------------------------------------------------------
        function v = get.MaximumEVM(this)
            v = this.EVM.MaximumEVM;
        end
        %-----------------------------------------------------------------------
        function v = get.PercentileEVM(this)
            v = this.EVM.PercentileEVM;
        end
        %-----------------------------------------------------------------------
        function v = get.MERdB(this)
            v = this.MER.MERdB;
        end
        %-----------------------------------------------------------------------
        function v = get.MinimumMER(this)
            v = this.MER.MinimumMER;
        end
        %-----------------------------------------------------------------------
        function v = get.PercentileMER(this)
            v = this.MER.PercentileMER;
        end
        %-----------------------------------------------------------------------
        function set.Percentile(this, v)
            this.EVM.Percentile = v;
            this.MER.Percentile = v;
            this.Percentile = v;
        end
    end
end
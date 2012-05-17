classdef SrcSignal < dynamicprops
    properties
        BlockPath;
        PortIndex;
        SigName;
        SampleTime;
        Timeseries;
    end
    methods
        function this = setprop(this,propName,propVal)
            this.(propName) = propVal;
        end
        function propval = getprop(this,propName)
            propval = this.(propName);
        end
        function this = SrcSignal(bpath, pindex, name, sampTime, ts)
            this.BlockPath = bpath;
            this.PortIndex = pindex;
            this.SigName = name;
            this.SampleTime = sampTime;
            this.Timeseries = ts;
        end
    end
end

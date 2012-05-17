classdef SrcDWork < dynamicprops
    properties
        BlockPath;
        DWorkName;
        DataType;
        Dimensions;
        IsComplex;
        Timeseries;
    end
    methods
        function this = setprop(this,propName,propVal)
            this.(propName) = propVal;
        end
        function propval = getprop(this,propName)
            propval = this.(propName);
        end
        function this = SrcDWork(bpath, name, dtype, dims, complex, ts)
            this.BlockPath = bpath;
            this.DWorkName = name;
            this.DataType = dtype;
            this.Dimensions = dims;
            this.IsComplex = complex;
            this.Timeseries = ts;
        end
    end
end

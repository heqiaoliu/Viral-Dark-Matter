function ret = getHardwareConfigs(varargin)
% GETHARDWARECONFIGS -- get the detailed information of model hardware configuration.
%
% Usage:
%   getHardwareConfigs('Production') returns the list of embedded hardware (production hardware) settings;
%   getHardwareConfigs('Target') returns the list of emulation hardware (target hardware) settings.
%

% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.18 $

ret = [];

% By default: enabled = false; visible = true;

tr = RTW.TargetRegistry.getInstance;
for idx = 1:length(tr.HWDeviceTypes)
	thisHW = tr.HWDeviceTypes(idx);
	configTable(idx).Name            = [thisHW.Vendor '->' thisHW.Type];
    if ~isempty(thisHW.Alias)
	configTable(idx).Type            = thisHW.Alias{1};
    else
        configTable(idx).Type = configTable(idx).Name;
    end
	configTable(idx).Char.Value      = thisHW.BitPerChar;
	configTable(idx).Char.Enabled    = thisHW.Enabled(igetPropIndex('BitPerChar'));
	configTable(idx).Char.Visible    = thisHW.Visible(igetPropIndex('BitPerChar'));
	configTable(idx).Short.Value     = thisHW.BitPerShort;
	configTable(idx).Short.Enabled   = thisHW.Enabled(igetPropIndex('BitPerShort'));
	configTable(idx).Short.Visible   = thisHW.Visible(igetPropIndex('BitPerShort'));
	configTable(idx).Int.Value       = thisHW.BitPerInt;
	configTable(idx).Int.Enabled     = thisHW.Enabled(igetPropIndex('BitPerInt'));
	configTable(idx).Int.Visible     = thisHW.Visible(igetPropIndex('BitPerInt'));
	configTable(idx).Long.Value      = thisHW.BitPerLong;
	configTable(idx).Long.Enabled    = thisHW.Enabled(igetPropIndex('BitPerLong'));
	configTable(idx).Long.Visible    = thisHW.Visible(igetPropIndex('BitPerLong'));
	configTable(idx).Float.Value     = thisHW.BitPerFloat;
	configTable(idx).Float.Enabled   = thisHW.Enabled(igetPropIndex('BitPerFloat'));
	configTable(idx).Float.Visible   = thisHW.Visible(igetPropIndex('BitPerFloat'));
	configTable(idx).Double.Value    = thisHW.BitPerDouble;
	configTable(idx).Double.Enabled  = thisHW.Enabled(igetPropIndex('BitPerDouble'));
	configTable(idx).Double.Visible  = thisHW.Visible(igetPropIndex('BitPerDouble'));
	configTable(idx).Pointer.Value    = thisHW.BitPerPointer;
	configTable(idx).Pointer.Enabled  = thisHW.Enabled(igetPropIndex('BitPerPointer'));
	configTable(idx).Pointer.Visible  = thisHW.Visible(igetPropIndex('BitPerPointer'));
	configTable(idx).LargestAtomicInt.Value   = thisHW.LargestAtomicInteger;
	configTable(idx).LargestAtomicInt.Enabled = thisHW.Enabled(igetPropIndex('LargestAtomicInteger'));
	configTable(idx).LargestAtomicInt.Visible = thisHW.Visible(igetPropIndex('LargestAtomicInteger'));
	configTable(idx).LargestAtomicFlt.Value   = thisHW.LargestAtomicFloat;
	configTable(idx).LargestAtomicFlt.Enabled = thisHW.Enabled(igetPropIndex('LargestAtomicFloat'));
	configTable(idx).LargestAtomicFlt.Visible = thisHW.Visible(igetPropIndex('LargestAtomicFloat'));
	configTable(idx).Endian.Value    = thisHW.Endianess;
	configTable(idx).Endian.Enabled  = thisHW.Enabled(igetPropIndex('Endianess'));
	configTable(idx).Endian.Visible  = thisHW.Visible(igetPropIndex('Endianess'));
	configTable(idx).NatWdSize.Value = thisHW.WordSize;
	configTable(idx).NatWdSize.Enabled = thisHW.Enabled(igetPropIndex('WordSize'));
	configTable(idx).NatWdSize.Visible = thisHW.Visible(igetPropIndex('WordSize'));
	configTable(idx).SftRht.Value    = thisHW.ShiftRightIntArith;
	configTable(idx).SftRht.Enabled  = thisHW.Enabled(igetPropIndex('ShiftRightIntArith'));
	configTable(idx).SftRht.Visible  = thisHW.Visible(igetPropIndex('ShiftRightIntArith'));
	configTable(idx).IntDiv.Value    = thisHW.IntDivRoundTo;
	configTable(idx).IntDiv.Enabled  = thisHW.Enabled(igetPropIndex('IntDivRoundTo'));
	configTable(idx).IntDiv.Visible  = thisHW.Visible(igetPropIndex('IntDivRoundTo'));
	configTable(idx).ForProd         = ismember('Prod', thisHW.Platform);
	configTable(idx).ForTarget       = ismember('Target', thisHW.Platform);

end

if nargin == 1
	name = varargin{1};
	if isempty(name)
		ret = configTable;
	else
		switch lower(name)
			case 'production'
				ret = configTable(find([configTable.ForProd]));
			case 'target'
				ret = configTable(find([configTable.ForTarget]));
			otherwise
				for i = 1:length(configTable)
					if strcmp(configTable(i).Type, name)
						ret = configTable(i);
						break;
					end
				end
		end
	end
else
	mode = varargin{1};
	val  = varargin {2};

	switch lower(mode)
		case 'type'
			for i = 1:length(configTable)
				if strcmp(configTable(i).Type, val)
					ret = configTable(i);
					break;
				end
			end

		case 'name'
			for i = 1:length(configTable)
				if strcmp(configTable(i).Name, val)
					ret = configTable(i);
					break;
				end
			end
	end
end


function val = igetPropIndex(Prop)

PropEnum = {'BitPerChar' 'BitPerShort' 'BitPerInt' 'BitPerLong' ...
    'WordSize' 'Endianess' 'IntDivRoundTo' 'ShiftRightIntArith' ...
    'BitPerFloat' 'BitPerDouble' 'BitPerPointer' 'LargestAtomicInteger' ...
    'LargestAtomicFloat'};
val = strmatch(Prop, PropEnum, 'exact');


% EOF

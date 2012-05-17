function out = util_randvalue(flatdimensions,numberTimeSteps,x)
%
%  Generate a random matrix with values that match the class of X.
%
%  We need a deterministic way to seed the random number
%  generator so that test cases will be deterministic in
%  the sense that the values are consistent from one call
%  to another.
%
%  The seed could be based upon invariant attributes of the
%  test component such as number of objectives and number or
%  model objects.
%

%   Copyright 2007-2009 The MathWorks, Inc.

    valint = 1;
    castFcn = class(x);
    isFi = false;
    isEnum = false;

    % Determine the correct max, min and castFcn
    switch(class(x))
      case 'double'
        valint = [];
        valmax = 1e26;
        valmin = -1e26;

      case 'single'
        valint = [];
        valmax = 1e26;
        valmin = -1e26;

      case 'logical'
        valmax = 1;
        valmin = 0;

      case {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32'}
        valmax = intmax(castFcn);
        valmin = intmin(castFcn);

      case 'embedded.fi'
        isFi = true;
        valmax = x.intmax();
        valmax = valmax.int;

        valmin = x.intmin();
        valmin = valmin.int;

      otherwise
        [isEnum, className] = sldvshareprivate('util_is_enum_type', class(x));
        if(isEnum)
            %Get a random value for the index into the enumeration
            enumVals = enumeration(className);
                valmin = 1;
                valmax = length(enumVals);
        end
    end

    valmax = double(valmax);
    valmin = double(valmin);

    rRaw = rand([flatdimensions numberTimeSteps]);
    rScaled = valmin + rRaw*(valmax - valmin);

    if isempty(valint)
        rfixed = rScaled;
    else
        rfixed = round(rScaled * (1/valint)) * valint;
    end

    if isFi
        out = fi(x.numerictype);
        out.int = rfixed;
    elseif isEnum
        out = enumVals(rfixed);
    else
        out = feval(castFcn,rfixed);
    end

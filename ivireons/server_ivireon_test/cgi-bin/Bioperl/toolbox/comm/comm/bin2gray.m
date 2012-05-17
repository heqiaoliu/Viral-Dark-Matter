function [output,mapping] = bin2gray(x,modulation,order)
%BIN2GRAY Gray encode
%   Y = BIN2GRAY(X,MODULATION,M) generates a Gray encoded output with the same
%   dimensions as its input parameter X.  The input X can be a scalar, vector or
%   matrix.  MODULATION is the modulation type, which can be a string equal to
%   'qam', 'pam', 'fsk', 'dpsk' or 'psk'.  M is the modulation order that must
%   be an integer power of two.
%
%   [Y,MAP] = BIN2GRAY(X,MODULATION,M) generates a Gray encoded output, Y and
%   returns its Gray encoded constellation map, MAP.  The constellation map is a
%   vector of numbers to be assigned to the constellation symbols.  The assumed
%   constellation symbols are same as the Constellation property of MODEM
%   objects.  Type 'help modem' to get more information on
%   MODEM objects.
%
%   If you are converting binary coded data to Gray coded data and modulating
%   the result immediately afterwards, you should use the appropriate modulation
%   object with the 'gray' option, instead of BIN2GRAY.
%
%   EXAMPLE: 
%     % To Gray encode a vector x with a 16-QAM Gray encoded constellation and
%     % return its map, use:
%     x=randi([0 15],1,100);
%     [y,map] = bin2gray(x,'qam',16);
%     
%     % Obtain the symbols for 16-QAM
%     hMod = modem.qammod('M', 16);
%     symbols = hMod.Constellation;
%
%     % Plot the constellation
%     scatterplot(symbols);
%     set(get(gca,'Children'),'Marker','d','MarkerFaceColor','auto');
%     hold on;
%     % Label the constellation points according to the Gray mapping
%     for jj=1:16
%       text(real(symbols(jj))-0.15,imag(symbols(jj))+0.15,...
%       dec2base(map(jj),2,4));
%     end
%     set(gca,'yTick',(-4:2:4),'xTick',(-4:2:4),...
%      'XLim',[-4 4],'YLim',...
%      [-4 4],'Box','on','YGrid','on', 'XGrid','on');
%
%   See also GRAY2BIN, MODEM, MODEM/TYPES, FSKMOD.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2009/01/05 17:45:02 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin validating inputs      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Typical error checking.
error(nargchk(3, 3, nargin,'struct'))

%Validate numeric x data
if isempty(x)
    error('comm:bin2gray:InputEmpty','Input data vector is empty.');
end

% x must be a scalar, vector or a 2D matrix
if length(size(x)) > 2
    error('comm:bin2gray:InputDimensions','Input data must be a scalar, vector or a 2D matrix.');
end

% x must be a finite non-negative integer
if (max(max(x < 0))) || (max(max(isinf(x)))) || (~isreal(x))||...
        (max(max(floor(x) ~= x)))
    error('comm:bin2gray:InputError','Input data must contain only finite real non-negative integers.');
end

% Validate modulation type
if (~ischar(modulation)) || (~strcmpi(modulation,'QAM')) && (~strcmpi(modulation,'PSK'))...
        && (~strcmpi(modulation,'FSK')) && (~strcmpi(modulation,'PAM')) && (~strcmpi(modulation,'DPSK'))

    error('comm:bin2gray:ModulationTypeError','Invalid modulation type.');

end

%Validate modulation order
if (order < 2) || (isinf(order) || ...
        (~isreal(order)) || (floor(log2(order)) ~= log2(order)))

    error('comm:bin2gray:ModulationOrderError','Modulation order must be a finite real positive - integer power of 2.');

end

% Check for overflows - when x is greater than the modulation order
if (max(max(x)) >= order)
    error('comm:bin2gray:XError','Elements of input X must be integers in the range [0, M-1].');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finished validating inputs      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Gray code conversion %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch lower(modulation)

    case {'psk','pam','fsk','dpsk'}

        % Calculate Gray table
        j = (0:order-1)';
        mapping = bitxor(j,bitshift(j,-1));

        % Format output and translate x (map) i.e. convert to Gray
        output = mapping(x+1);
        % Assure that the output, if one dimensional,
        % has the correct orientation
        wid = size(x,1);
        if(wid == 1)
            output = output';
        end

    case {'qam'}

        k = log2(order);                % Number of bits per symbol
        mapping = (0:order-1)';         % Binary mapping to be Gray converted
        if rem(k,2) % non-square constellation

            kI = (k+1)/2;
            kQ = (k-1)/2;

            symbolI = bitshift(mapping,-kQ);
            symbolQ = bitand(mapping,bitshift(order-1,-kI));

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < kI
                tempI = symbolI;
                tempI = bitshift(tempI,-i);
                symbolI = bitxor(symbolI,tempI);
                i = i + i;                          % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < kQ
                tempQ = symbolQ;
                tempQ = bitshift(tempQ,-i);
                symbolQ = bitxor(symbolQ, tempQ);
                i = i + i;                          % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            SymbolIndex = double(bitshift(symbolI,kQ) + symbolQ);

        else % square constellation

            symbolI = bitshift(mapping,-k/2);
            symbolQ = bitand(mapping,bitshift(order-1,-k/2));

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < k/2
                tempI = symbolI;
                tempI = bitshift(tempI,-i);
                symbolI = bitxor(symbolI,tempI);

                tempQ = symbolQ;
                tempQ = bitshift(tempQ,-i);
                symbolQ = bitxor(symbolQ, tempQ);
                i = i + i;                          % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            SymbolIndex = double(bitshift(symbolI,k/2) + symbolQ);

        end

        mapping = SymbolIndex;
        %Format output and translate x (map) i.e. convert to Gray
        output = mapping(x+1);
        % Assure that the output, if one dimensional,
        % has the correct orientation
        if any(size(x) ~= size(output))
            output = output';
        end
        
        % Make sure that mapping is a vector, when used to name the symbols
        % column-wise starting from left upper corner, results in a gray mapped
        % constellation.
        [dummy,index]=ismember(0:order-1,mapping);
        mapping = index - 1;

    otherwise
        error('comm:bin2gray:ModulationTypeUnknown','Unknown modulation method.')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Gray code conversion   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
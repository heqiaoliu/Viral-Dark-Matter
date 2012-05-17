function refreshpzeditfields(Editor,idxPZ)
%REFRESHPZEDITFIELDS  Refreshes the edit selection fields

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2006/06/20 20:03:12 $

% get handles
idxC = Editor.idxC;
PZTabHandles = Editor.Handles.PZTabHandles;

Group = Editor.CompList(idxC).PZGroup(idxPZ);
Ts=Editor.CompList(idxC).Ts;
PrecisionFormat = Editor.PrecisionFormat;
FreqUnits = Editor.FrequencyUnits;

if ~isempty(Group)
    switch Group.Type
        case 'Real'
            % Real pole/zero
            if isempty(Group.Pole)
                Location = Group.Zero;
            else
                Location = Group.Pole;
            end
            
            % Update text fields in card
            EditR1=PZTabHandles.EditR1;
            LocalUpdateField(EditR1,sprintf(PrecisionFormat, Location));
            

        case 'Complex'
            % Complex pole/zero
            if isempty(Group.Pole)
                Location = Group.Zero(1);
            else
                Location = Group.Pole(1);
            end
            [Wn, Z] = damp(Location, Ts);
            Z(Z==0) = 0; %Prevent sprintf form printing -0 for non-pc

            EditCWn = PZTabHandles.EditCWn;
            EditCZeta = PZTabHandles.EditCZeta;
            EditCR = PZTabHandles.EditCR;
            EditCI = PZTabHandles.EditCI;

            % Update text fields in card
            LocalUpdateField(EditCWn, sprintf(PrecisionFormat,  unitconv(Wn,'rad/sec',FreqUnits)));
            LocalUpdateField(EditCZeta, sprintf(PrecisionFormat, Z));
            LocalUpdateField(EditCR, sprintf(PrecisionFormat, real(Location)));
            LocalUpdateField(EditCI, sprintf(PrecisionFormat, imag(Location)));
            

        case 'LeadLag'
            EditLLZ = PZTabHandles.EditLLZ;
            EditLLP = PZTabHandles.EditLLP;
            EditLLPhase = PZTabHandles.EditLLPhase;
            EditLLFreq = PZTabHandles.EditLLFreq;
            ZeroLocation = Group.Zero;
            PoleLocation = Group.Pole;
            
            % Update pole/zero text fields in card
            LocalUpdateField(EditLLZ, sprintf(PrecisionFormat, ZeroLocation));
            LocalUpdateField(EditLLP, sprintf(PrecisionFormat, PoleLocation));
                       
            if (Ts ~= 0)
                % discrete case
                ZeroLocation = log(ZeroLocation)/Ts;
                PoleLocation = log(PoleLocation)/Ts;
            end
            
            % Calculate the maximum phase addition from lead/lag and freq
            % at which it occurs
            alpha = ZeroLocation/PoleLocation;
            phasemax = asin((1-alpha)/(1+alpha))/pi*180;
            wmax = -ZeroLocation/sqrt(alpha);
            
            % Update max phase/freq text fields in card
            LocalUpdateField(EditLLPhase, sprintf(PrecisionFormat, phasemax));
            LocalUpdateField(EditLLFreq, sprintf(PrecisionFormat, unitconv(wmax,'rad/sec',FreqUnits)));
           

        case 'Notch'
            % Notch filter.
            EditNWn = PZTabHandles.EditNWn;
            EditNZZeta = PZTabHandles.EditNZZeta;
            EditNPZeta = PZTabHandles.EditNPZeta;
            EditNDepth = PZTabHandles.EditNDepth;
            EditNWidth = PZTabHandles.EditNWidth;

            ZeroLocation = Group.Zero(1);
            [Wn, Zz] = damp(ZeroLocation, Ts);
            Zz(Zz==0) = 0; %Prevent sprintf form printing -0 for non-pc
            PoleLocation = Group.Pole(1);
            [Wn, Zp] = damp(PoleLocation, Ts);
            Zp(Zp==0) = 0; %Prevent sprintf form printing -0 for non-pc
            
            % Calculate notch width and depth
            ndepth = Zz/Zp;
            nwidth = Localnotchwidth(ndepth, Zp);
            
            % Update text fields in card
            LocalUpdateField(EditNWn, sprintf(PrecisionFormat, unitconv(Wn,'rad/sec',FreqUnits)));
            LocalUpdateField(EditNZZeta, sprintf(PrecisionFormat, Zz));
            LocalUpdateField(EditNPZeta, sprintf(PrecisionFormat, Zp));
            LocalUpdateField(EditNDepth, sprintf(PrecisionFormat, 20*log10(ndepth)));
            LocalUpdateField(EditNWidth, sprintf(PrecisionFormat, nwidth));                       
    end
end



%----------------------------Local Functions-------------------------------

% ------------------------------------------------------------------------%
% Function: LocalUpdateField 
% Purpose:  Updates text field and stores string in userdata
% ------------------------------------------------------------------------%
function LocalUpdateField(src,tstring)
awtinvoke(src,'setText(Ljava/lang/String;)',java.lang.String(tstring));
set(src,'UserData',tstring);


% ------------------------------------------------------------------------%
% Function: Localnotchwidth
% Purpose:  Calculates log notch width
% ------------------------------------------------------------------------%
function width = Localnotchwidth(depth,zeta2)
% Calculate notch width at percent depth p
%      s^2 + (2*Zeta1^2)*s + wn^2
% G(s)--------------
%      s^2 + (2*Zeta2^2)*s + wn^2
%
% Depth = Zeta1/Zeta2

p=.25; % percent depth for width calculation
alpha = depth^p;
if alpha == 1
    % alpha = 1 -> G(s)=1 Pole/Zero Cancelation
    width = NaN;
else
    % Calculate log width
    Beta =sqrt(zeta2^2*(alpha^2-depth^2)/(1-alpha^2));
    width = log10(1 + 2*Beta^2 + 2*Beta*sqrt(1+Beta^2));
end
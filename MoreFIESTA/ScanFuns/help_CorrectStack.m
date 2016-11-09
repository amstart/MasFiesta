function [ Stack ] = help_CorrectStack(Stack, PathName, PixSize)
%CORRECTSTACK Corrects one channel in a stack, loading the Drift and the
%offset map from files within the same folder as the File from which the
%Objects were loaded
global ScanOptions
if ~isfield(ScanOptions, 'help_CorrectStack') || ~isfield(ScanOptions.help_CorrectStack, 'CorrectColor')
    button = fQuestDlg('What should be corrected?','What?',{'Color (loads ''offset.mat'')','Drift (loads ''drift.mat'')', 'Both'},'Both', 'noplacefig');
    if strcmp(button,'Color (loads ''offset.mat'')')
        ScanOptions.help_CorrectStack.CorrectColor = 0;
        ScanOptions.help_CorrectStack.CorrectDrift = 0;
    elseif strcmp(button,'Drift (loads ''drift.mat'')')
        ScanOptions.help_CorrectStack.CorrectColor = 0;
        ScanOptions.help_CorrectStack.CorrectDrift = 1;
    elseif strcmp(button,'Both')
        ScanOptions.help_CorrectStack.CorrectColor = 1;
        ScanOptions.help_CorrectStack.CorrectDrift = 1;
    end
    if ScanOptions.help_CorrectStack.CorrectColor || ScanOptions.help_CorrectStack.CorrectDrift
        button = fQuestDlg('Which interpolation method should be used?','Choose Interpolation Method',{'Nearest(fast)','Linear(slow)'},'Nearest(fast)', 'noplacefig');
        if strcmp(button,'Nearest(fast)')
            ScanOptions.help_CorrectStack.linear = 0;
        elseif strcmp(button,'Linear(slow)')
            ScanOptions.help_CorrectStack.linear = 1;
        end
    end
end
if (ScanOptions.help_CorrectStack.CorrectDrift || ScanOptions.help_CorrectStack.CorrectColor) && ~isfield(ScanOptions, 'Channel')
    input = inputdlg('Correct which channel?','Channel',1,{'2'});
    ScanOptions.Channel = str2double(input);
end
if ScanOptions.help_CorrectStack.CorrectColor
    for offsetfilename = {'OffSet.mat', 'Offset.mat', 'offset.mat', 'offSet.mat'}
        try
            OffsetMap = load([PathName offsetfilename{1}]);
            break
        catch
        end
    end
    TformChannel = OffsetMap.OffsetMap(ScanOptions.Channel-1).T;
else
    TformChannel = [1 0 0;0 1 0;0 0 1];
end
if ScanOptions.help_CorrectStack.CorrectDrift
    try
        Drift = load([PathName 'Drift.mat']);
    catch
        Drift = load([PathName 'drift.mat']);
    end
    Drift = Drift.Drift{ScanOptions.Channel-1};
else
    Drift = [];
end
%% Do work
[y,x,z] = size(Stack); 
T = TformChannel;
X = repmat(1:x,y,1);
Y = repmat(1:y,1,x);

X = X(:);
Y = Y(:);

T = [ T(1,1) -T(1,2) 0; -T(2,1) T(2,2) 0; -T(3,1)*T(1,1)-T(3,2)*T(1,2) -T(3,2)*T(1,1)+T(3,1)*T(1,2) 1];

TX = X * T(1,1) + Y * T(2,1) + T(3,1);
TY = X * T(1,2) + Y * T(2,2) + T(3,2);

if isempty(Drift)
    NX = TX;
    NY = TY;
    if ScanOptions.help_CorrectStack.linear
        k = NX<1 | NX>x | NY<1 | NY>y;
        NX(k) = [];
        NY(k) = [];
        X(k) = [];
        Y(k) = [];
        idx = Y + (X - 1).*y;
        NX1 = fix(NX);
        NX2 = ceil(NX);
        NY1 = fix(NY);
        NY2 = ceil(NY);
        idx11 = NY1 + (NX1 - 1).*y;
        idx12 = NY2 + (NX1 - 1).*y;
        idx21 = NY1 + (NX2 - 1).*y;
        idx22 = NY2 + (NX2 - 1).*y;
        W11=(NX2-NX).*(NY2-NY);
        W12=(NX2-NX).*(NY-NY1);
        W21=(NX-NX1).*(NY2-NY);
        W22=(NX-NX1).*(NY-NY1);
    else
        NX = round(NX);
        NY = round(NY);
        k = NX<1 | NX>x | NY<1 | NY>y;
        NX(k) = [];
        NY(k) = [];
        X(k) = [];
        Y(k) = [];
        idx = Y + (X - 1).*y;
        tidx = NY + (NX - 1).*y;
    end
    for n = 1:z   
        I = Stack(:,:,n);
        if ScanOptions.help_CorrectStack.linear
            NI = zeros(y,x);
            I = double(I);
            NI(idx) = I(idx11).*W11+...
                  I(idx21).*W21+...
                  I(idx12).*W12+...
                  I(idx22).*W22;
            NI = uint16(NI);
        else
            NI = zeros(y,x,'like',I);
            NI(idx) = I(tidx);
        end
        Stack(:,:,n) = NI;
    end
else
    for n = 1:z  
        k=find(Drift(:,1)==n);
        if isempty(k)
            NX = TX;
            NY = TY;
        else
            NX = TX+Drift(k,2)/PixSize;
            NY = TY+Drift(k,3)/PixSize;
        end
        Stack(:,:,n) = QuickInterpol(Stack(:,:,n),X,Y,NX,NY,ScanOptions.help_CorrectStack.linear);
    end
end


function NI = QuickInterpol(I,X,Y,NX,NY,linear)
[y,x] = size(I);
if linear
    k = NX<1 | NX>x | NY<1 | NY>y;
    NX(k) = [];
    NY(k) = [];
    X(k) = [];
    Y(k) = [];
    idx = Y + (X - 1).*y;
    I = double(I);
    NI = zeros(y,x);
    NX1 = fix(NX);
    NX2 = ceil(NX);
    NY1 = fix(NY);
    NY2 = ceil(NY);
    if all(NX1==NX2) && all(NX1==NX2) 
        NI = uint16(I);
    else
        idx11 = NY1 + (NX1 - 1).*y;
        idx12 = NY2 + (NX1 - 1).*y;
        idx21 = NY1 + (NX2 - 1).*y;
        idx22 = NY2 + (NX2 - 1).*y;
        W11=(NX2-NX).*(NY2-NY);
        W12=(NX2-NX).*(NY-NY1);
        W21=(NX-NX1).*(NY2-NY);
        W22=(NX-NX1).*(NY-NY1);
        NI(idx) = I(idx11).*W11+...
                  I(idx21).*W21+...
                  I(idx12).*W12+...
                  I(idx22).*W22;
        NI = uint16(NI);
    end
else
    NI = zeros(y,x,'like',I);
    NX = round(NX);
    NY = round(NY);
    k = NX<1 | NX>x | NY<1 | NY>y;
    NX(k) = [];
    NY(k) = [];
    X(k) = [];
    Y(k) = [];
    idx = Y + (X - 1).*y;
    tidx = NY + (NX - 1).*y;
    NI(idx) = I(tidx);
end
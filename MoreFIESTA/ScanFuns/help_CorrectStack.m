function [ Stack ] = help_CorrectStack(Stack, Drift, TformChannel )
%CORRECTSTACK Summary of this function goes here
%   Detailed explanation goes here
global ScanOptions
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
    if ScanOptions.linear
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
        if ScanOptions.linear
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
            NX = TX+Drift(k,2)/ScanOptions.PixSize;
            NY = TY+Drift(k,3)/ScanOptions.PixSize;
        end
        Stack(:,:,n) = QuickInterpol(Stack(:,:,n),X,Y,NX,NY,ScanOptions.linear);
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
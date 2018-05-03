function [KymoGraph,KymoPix] = fJKNewKymo(Scan, Stack)
%This function creates flexible multi-color kymographs. Always does
%a color correction if a Colormap is present and the Stack has not been
%corrected. The color correction is always done before drift correction.
%Based on NewKymo within fRightPanel
hMainGui=getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
iX=Scan.InterpX;
iY=Scan.InterpY;
d = Scan.InterpD;
KymoPix = mean(d(2:end)-d(1:end-1));
stidx=1:numel(Stack);
N = size(Stack{1},3);
divisor = zeros(stidx(end),1);
for k = stidx
    if mod(size(Stack{stidx(1)},3),size(Stack{k},3)-1)<2
        divisor(k)=round(N/(size(Stack{k},3)-1));%shorter stack starts and finishes with the the longer one
    else
        divisor(k)=N/size(Stack{k},3);
    end
end
correctDrift = get(hMainGui.RightPanel.pTools.cKymoDrift,'Value')==1 && ~isempty(Drift) && strcmp(get(hMainGui.RightPanel.pTools.cKymoDrift,'Enable'),'on');
if correctDrift
    max_l_Drift=size(Drift{1},1);
    for k = stidx
        if isempty(Drift{k})
            Drift{k}=[1 0 0];
        end
        if k~=1&&size(Drift{k},1)>1
            Drift{k} = interp1((Drift{k}(:,1)-1).*divisor(k)+1,Drift{k},1:max_l_Drift);
            Drift{k}(:,1) = 1:max_l_Drift;
        elseif k~=1&&size(Drift{k},1)==1
            Drift{k} = repmat(Drift{k}, max_l_Drift,1);
            Drift{k}(:,1) = 1:max_l_Drift;
        end
    end
end
progressdlg('String','Creating KymoGraph','Min',0,'Max',length(stidx),'Parent',hMainGui.fig);
KymoGraph = zeros(N,length(d),length(stidx)); 
OffsetMap = getappdata(hMainGui.fig,'OffsetMap');
if isempty(OffsetMap) || strcmp(get(hMainGui.Menu.mCorrectStack,'Checked'),'on');
    CorrectColor=0;
else
    CorrectColor=1;
end
if correctDrift
    if get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==1
        for k = stidx
            if k~=1 && CorrectColor && length(OffsetMap)>k-2 && 0
                [iXc, iYc] = transformPointsInverse(affine2d(OffsetMap(k-1).T),iX, iY);
            else
                iXc = iX;
                iYc=iY;
            end
            for n = 1:N
                [~,m]=min(abs(Drift{k}(:,1)-n));
                Z = interp2(double(Stack{k}(:,:,ceil(n/divisor(k)-1e-8))),iXc+Drift{k}(m,2)/hMainGui.Values.PixSize,iYc+Drift{k}(m,3)/hMainGui.Values.PixSize,'nearest');
                KymoGraph(n,:,k)=max(Z,[],1);
            end
            progressdlg(find(stidx==k));
        end
    elseif get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==2
        for k = stidx
            if k~=1 && CorrectColor && length(OffsetMap)>k-2
                [iXc, iYc] = transformPointsInverse(affine2d(OffsetMap(k-1).T),iX, iY);
            else
                iXc = iX;
                iYc=iY;
            end
            for n = 1:N
                [~,m]=min(abs(Drift{k}(:,1)-n));
                Z = interp2(double(Stack{k}(:,:,ceil(n/divisor(k)-1e-8))),iXc+Drift{k}(m,2)/hMainGui.Values.PixSize,iYc+Drift{k}(m,3)/hMainGui.Values.PixSize,'nearest');
                KymoGraph(n,:,k)=mean(Z,1);
            end
            progressdlg(find(stidx==k));
        end
    end
else
    if get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==1
        for k = stidx
            if k~=1 && CorrectColor && length(OffsetMap)>k-2
                [iXc, iYc] = transformPointsInverse(affine2d(OffsetMap(k-1).T),iX, iY);
            else
                iXc = iX;
                iYc=iY;
            end
            for n = 1:N
                Z = interp2(double(Stack{k}(:,:,ceil(n/divisor(k)-1e-8))),iXc,iYc,'nearest');
                KymoGraph(n,:,k)=max(Z,[],1);
            end
            progressdlg(find(stidx==k));
        end
    elseif get(hMainGui.RightPanel.pTools.mKymoMethod,'Value')==2
        for k = stidx
            if k~=1 && CorrectColor && length(OffsetMap)>k-2
                [iXc, iYc] = transformPointsInverse(affine2d(OffsetMap(k-1).T),iX, iY);
            else
                iXc = iX;
                iYc=iY;
            end
            for n = 1:N
                Z = interp2(double(Stack{k}(:,:,ceil(n/divisor(k)-1e-8))),iXc,iYc,'nearest');
                KymoGraph(n,:,k)=mean(Z,1);
            end
            progressdlg(find(stidx==k));
        end
    end
end
KymoGraph(isnan(KymoGraph))=0;
KymoGraph = KymoGraph(:,:,stidx);
function plotTrackSlide(varargin)
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
tracknum = str2num(get(hDFGui.eTrack, 'String'));
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);

figure('Position', [100 100 1000 800])
slmin = 1;
slmax = size(track.itrace,1);
       
bTag = uicontrol('Tag','lDim1','String','Tag','Position',[130 5 30 20],'Style','pushbutton');

lTag = uicontrol('Tag','lTags','String',{'none', '2much noise', 'pos ok', 'trash','maybe','rescue'},'Position',[200 5 150 20],'Style','popupmenu', 'Value',4);

plotTrack(tracknum, 1, lTag);

hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[1 1]./(slmax-slmin),'Value',4,...
                'Position',[20 5 100 20]);
set(hsl,'Callback',@(hObject,eventdata) plotTrack(tracknum, hObject, lTag));


% bFit = uicontrol('Style','pushbutton','String','Fit','Position',[300 5 60 20]);
% bDelete = uicontrol('Style','pushbutton','String','Delete','Position',[400 5 60 20]);
% bMark = uicontrol('Style','pushbutton','String','Mark','Position',[500 5 60 20]);
% set(bFit,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, 1));
% set(bDelete,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, 2));
% set(bMark,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, 3));
set(lTag,'Callback',@(hObject,eventdata) tagframe(tracknum, hsl, lTag, 0));
set(bTag,'Callback',@(hObject,eventdata) tagframe(tracknum, hsl, lTag, 1));
bZoomOut = uicontrol('Style','pushbutton','String','Zoom out','Position',[800 5 60 20], 'Callback','xlim auto');
bZoomOut = uicontrol('Style','pushbutton','String','Zoom in','Position',[900 5 60 20], 'Callback','xlim([-1500 1500])');


function plotTrack(tracknum, hsl, lTag)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
if ~isnumeric(hsl)
    frame = round(get(hsl,'Value'));
else
    frame = 1;
end
if ~all(isnan(track.itrace(frame,:)))
    iframe = frame - 4;
    tipx = - track.Data(2:end-10,2);
    itrace = track.itrace(frame,:);
    x = double((((0:length(itrace)-1)-28)*157/4) + tipx(1));
    plot(-x,itrace,'g--');
%     return
%     if isnan(track.Data(frame,2))
%         if frame+1 > size(track.Data,1)
%             xlim([x(1) track.Data(frame-1,2)+500]);
%         else
%             xlim([x(1) track.Data(frame+1,2)+500]);
%         end
%     else
%         xlim([x(1) track.Data(frame,2)+500]);
%     end
    hold on
    bg = nanmean(track.itrace(1:5,:));
    yn = itrace-bg;   
    plot(-x,yn,'r--');
    plot(-x,bg,'k--');
%     plot(x,itrace./track.itrace(1,:) .* mean(itrace));
    datacursormode on
% 
    if ~isnan(track.tags(frame))
        set(gca,'Color',[1 1 1] - 0.15 * track.tags(frame));
    elseif iframe > 0
        set(gca,'Color',[1 1 1-0.1*sum(track.protoFa(iframe,:))]);
    else
        set(gca,'Color',[1 1 1]);
    end

    if iframe > 0
    GFPTip = track.GFPTip(iframe);
    [~,idGFPTip] = min(abs(x-GFPTip));
    plot(-x,[itrace(1:idGFPTip) yn(idGFPTip+1:end)+itrace(idGFPTip+1)-yn(idGFPTip+1)]);
%     return
    if iframe > 1
        if iframe < length(tipx)
            vline(-mean(tipx(iframe-1:iframe)));
        else
            vline(-tipx(end));
        end
    else
        vline(-tipx(iframe));
    end
    
    minima = track.minima(iframe,:);
    vline(-GFPTip,'g:');
    if ~isnan(minima(1))
        vline(-x(minima), 'b:');
    end
    data = fitFrame.getPlotData(track,[2 6]);
    data = squeeze(data(iframe,:,:));
    fdata = double(data(3:end,:));
    

    h1 = plot(-x,fitFrame.fun1(x,fdata(:,1)));

    h6 = plot(-x,fitFrame.fun1(x,fdata(:,2)));
    
%     vline(fdata(5,7),'k:');
%     vline(fdata(5,7)+fdata(6,7),'y');
    text(-GFPTip, 1, {['v = ' num2str(data(2,2))]});

%     legend([h1 h2 h3 h4 h5 h6],...
%     {['e=' num2str(data(10,1),3)],...
%     ['A=' num2str(data(1,2),3) ' s=' num2str(data(2,2),3) 'e=' num2str(data(10,2),3)],...
%     ['sh=' num2str(data(6,3),3) ' e=' num2str(data(10,3),3)],...
%     ['sigdiff=' num2str(diff(data([2 7],4)),3) ' e=' num2str(data(10,4),3)],...
%     ['sigdiff=' num2str(diff(data([2 7],5)),3) ' e=' num2str(data(10,5),3)],...
%     [' s=' num2str(data(2,6),3) ' t=' num2str(data(8,6),3) ' e=' num2str(data(10,6),3)]},...
%     'Location', 'southeast');

    title(['MT: ' num2str(track.MTIndex) ' track: ' num2str(track.TrackIndex)...
        '   frame: ' num2str(iframe) '/' num2str(track.frames(iframe,:)) '   time: ' num2str(track.TimeInfo(track.frames(iframe,2)),3)...
        '   # protoF: ' num2str(track.protoFn)]);
    else
    title(['MT: ' num2str(track.MTIndex) ' track: ' num2str(track.TrackIndex)...
        '   frame: ' num2str(iframe)]);
    end
%     try
%         h1 = plot(x,convolutedExponential(x,track.Data(frame,7:end-1,dim1)'));
%         h2 = plot(x,convolutedExponential(x,track.Data(frame,7:end-1,dim2)'));
%     catch
%     end
%     plot(track.x_sel{frame}([1 end]),[mean(ylim) mean(ylim)]);
try
    tubframedat = find(track.framestub(:,2)==track.frames(iframe,1));
    itracetub = (itrace(idGFPTip).*track.itracetub(tubframedat,:))./max(track.itracetub(tubframedat,:));
    plot(-x,itracetub,'k');
catch
end
    ylabel('Ase1 count [1]');
    xlabel('Distance from seed [nm]');
    drawnow;
    hold off
end

function tagframe(tracknum, hsl, lTag, mode)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
frame = round(get(hsl,'Value'));

if ~isnan(track.tags(frame)) && mode || get(lTag,'Value') == 1
    track.tags(frame) = nan;
else
    track.tags(frame) = get(lTag,'Value');
end
Tracks(tracknum) = track;
setappdata(hDFGui.fig,'Tracks', Tracks);
setappdata(0,'hDFGui',hDFGui);
plotTrack(tracknum, hsl, lTag)
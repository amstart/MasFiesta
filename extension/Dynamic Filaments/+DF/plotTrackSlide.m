function plotTrackSlide(varargin)
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
tracknum = str2num(get(hDFGui.eTrack, 'String'));
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);

figure
slmin = 1;
slmax = size(track.itrace,1);

dimstr = strsplit(num2str(1:8));       
lDim1 = uicontrol('Tag','lDim1','String',dimstr,'Position',[150 5 30 20],'Style','popupmenu', 'Value',1);
lDim2 = uicontrol('Tag','lDim2','String',dimstr,'Position',[190 5 30 20],'Style','popupmenu', 'Value',2);
lDim3 = uicontrol('Tag','lDim3','String',dimstr,'Position',[230 5 30 20],'Style','popupmenu', 'Value',3);

lTag = uicontrol('Tag','lTags','String',{'None','Seed','PF','Rising MT C','Special', 'Seed and PF', 'into seed', 'PF out of range'},'Position',[600 5 150 20],'Style','popupmenu', 'Value',1);

plotTrack(tracknum, lDim1, lDim2, lDim3, 1, lTag);

hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                'Position',[20 5 100 20]);
set(hsl,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hObject, lTag));

set(lDim1,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hsl, lTag));
set(lDim2,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hsl, lTag));
set(lDim3,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hsl, lTag));

bFit = uicontrol('Style','pushbutton','String','Fit','Position',[300 5 60 20]);
bDelete = uicontrol('Style','pushbutton','String','Delete','Position',[400 5 60 20]);
bMark = uicontrol('Style','pushbutton','String','Mark','Position',[500 5 60 20]);
set(bFit,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, 1));
set(bDelete,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, 2));
set(bMark,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, 3));
set(lTag,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, 4));

bZoomOut = uicontrol('Style','pushbutton','String','Zoom out','Position',[800 5 60 20], 'Callback','xlim auto');
bZoomOut = uicontrol('Style','pushbutton','String','Zoom in','Position',[900 5 60 20], 'Callback','xlim([-1500 1500])');


function plotTrack(tracknum, lDim1, lDim2, lDim3, hsl, lTag)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
if ~isnumeric(hsl)
    frame = round(get(hsl,'Value'));
else
    frame = 6;
end
% dim1 = get(lDim1, 'Value');
% dim2 = get(lDim2, 'Value');
% dim3 = get(lDim3, 'Value');
dims = 1:6;
if ~all(isnan(track.itrace(frame,:)))
    iframe = frame - 4;
    tipx = - track.Data(2:end-10,2);
    itrace = track.itrace(frame,:);
    x = (((0:length(itrace)-1)-40)*157/4) + tipx(1);
    plot(x,itrace);
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
    ym = itrace-nanmean(track.itrace(1:6,:));   
    plot(x,ym);
%     plot(x,itrace./track.itrace(1,:) .* mean(itrace));
    datacursormode on

%     if ~isnan(track.tags(frame))
%         set(gca,'Color',[1 1 1] - 0.1 * track.tags(frame));
%     else
%         set(gca,'Color',[1 1 1]);
%     end

    if iframe > 0
    GFPTip = track.GFPTip(iframe);
    [~,idGFPTip] = min(abs(x-GFPTip));
    plot(x,[itrace(1:idGFPTip) ym(idGFPTip+1:end)+itrace(idGFPTip+1)-ym(idGFPTip+1)]);
    if iframe > 1
        if iframe < length(tipx)
            vline(mean(tipx(iframe-1:iframe)));
        else
            vline(tipx(end));
        end
    else
        vline(tipx(iframe));
    end
    
    minima = track.minima(iframe,:);
    vline(GFPTip,'g:');
    if ~isnan(minima(1))
        vline(x(minima), 'b:');
    end
    data = squeeze(track.FitData(iframe,dims,:))';
    if ~isnan(data(1))
    h1 = plot(x,fitFrame.fun2(x,data(:,1)));
    h2 = plot(x,fitFrame.fun2(x,data(:,2)));
    h3 = plot(x,fitFrame.fun2(x,data(:,3)));
    h4 = plot(x,fitFrame.fun2(x,data(:,4)));
    vline(data(5,4),'k:');
    text(data(5,4), 1, ['v = ' num2str(track.Data2(iframe,3))]);
    h5 = plot(x,fitFrame.fun2(x,data(:,5)));
    h6 = plot(x,fitFrame.fun1(x,data(:,6)),'k.');
%     legend([h1 h2 h3 h4 h5 h6],...
%     {['e=' num2str(data(10,1),3)],...
%     ['A=' num2str(data(1,2),3) ' s=' num2str(data(2,2),3) 'e=' num2str(data(10,2),3)],...
%     ['sh=' num2str(data(6,3),3) ' e=' num2str(data(10,3),3)],...
%     ['sigdiff=' num2str(diff(data([2 7],4)),3) ' e=' num2str(data(10,4),3)],...
%     ['sigdiff=' num2str(diff(data([2 7],5)),3) ' e=' num2str(data(10,5),3)],...
%     [' s=' num2str(data(2,6),3) ' t=' num2str(data(8,6),3) ' e=' num2str(data(10,6),3)]},...
%     'Location', 'southeast');
    end
    title(['MT: ' num2str(track.MTIndex) ' track: ' num2str(track.TrackIndex)...
        '   frame: ' num2str(iframe) '/' num2str(track.frames(iframe,:)) '   time: ' num2str(track.TimeInfo(track.frames(iframe,2)),3)]);
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
    drawnow;
    hold off
end

function fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, lTag, mode)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
frame = round(get(hsl,'Value'));
% dim1 = get(lDim1, 'Value');
% dim2 = get(lDim2, 'Value');
% dim3 = get(lDim3, 'Value');
dims = 1:6;
if ~isnan(track.itrace(frame,1))
    if mode < 3
        track.FitData(frame,dims,1:end-1, 1) = nan;
    end
    if mode == 1
        hdt = datacursormode;
        c_info = getCursorInfo(hdt);
        if isempty(c_info)
            pts = track.x_sel(frame,:);
        else
            pts = sort([c_info.DataIndex]);
        end
        y = track.itrace(frame,:);
        x = ((0:length(y)-1)-40)*(157/4) - track.Data(1,2);
        bg2 = max(min(y(1:40)),0);
        yp = y(pts(1):pts(end));
        xp = double(x(pts(1):pts(end)));
        bg1 = yp(end) - bg2;
        [fits0] = fitFrame.para_fit_erf(xp, yp, bg1, bg2);
        [fits1] = fitFrame.para_fit_gauss1(xp, yp, bg1, bg2);
        [fits2] = fitFrame.para_fit_gauss2(xp, yp, bg1, bg2);
        [fits3] = fitFrame.para_fit_gauss3(xp, yp, bg1, bg2);
        [fits4] = fitFrame.para_fit_gauss4(xp, yp, bg1, bg2);
        [fits5] = fitFrame.para_fit_exp(xp, yp, bg1, bg2);
        fits = padcat(fits0, fits1, fits2, fits3, fits4, fits5);
        if length(pts) == 3
            track.x_sel(frame,:) = pts;
        else
            track.x_sel(frame,[1 3]) = pts;
            track.x_sel(frame,2) = nan;
        end
        track.FitData(frame,1:size(fits,1),1:size(fits,2),1) = fits;
    end
    if mode > 2
        if (~isnan(track.Tags(frame)) && mode == 3) || get(lTag,'Value') == 1
            track.Tags(frame) = nan;
        else
            track.Tags(frame) = get(lTag,'Value');
        end
    end
    Tracks(tracknum) = track;
    setappdata(hDFGui.fig,'Tracks', Tracks);
    setappdata(0,'hDFGui',hDFGui);
    plotTrack(tracknum, lDim1, lDim2, lDim3, hsl, lTag)
end
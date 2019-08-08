function [x_vec, y_vec] = get_plot_vectors(Options, Tracks, xy)
vector = cell(1,2);
selected_methods = [Options.lMethod_TrackValue.val, Options.lMethod_TrackValueY.val];
selected_vars = [Options.lPlot_XVar.val, Options.lPlot_YVar.val];
for m = 1:length(xy)
    vector{m} = nan(length(Tracks),1);
    for n = 1:length(Tracks) % {'median', 'mean', 'end-start', 'minimum', 'maximum', 'standard dev', 'linear fit (only for velocity) or sum (only for MAP count)'}
        if isfield(Tracks(n), 'X')
            if m==1
                data = Tracks(n).X;
            else
                data = Tracks(n).Y;
            end
        else
            try
            data = Tracks(n).Data(:,selected_vars(m));
            catch
                return
            end
        end
        switch selected_methods(m)
            case 1
                vector{m}(n) = nanmedian(data);
            case 2
                vector{m}(n) = nanmean(data);
            case 3
                if selected_vars(m) == 3
                    vector{m}(n) = Tracks(n).Startendvel;
                else
                    vector{m}(n) = data(end) - data(1);
                end
            case 4
                vector{m}(n) = min(data);
            case 5
                vector{m}(n) = max(data);
            case 6
                if isfield(Tracks(n), 'X')
                    vector{m}(n) = (data(end) - data(1))/(Tracks(n).Z(end)-Tracks(n).Z(1));
                end
            case 7
                if selected_vars(m) == 3
                    if isfield(Tracks, 'Subsegvel')
                        vector{m}(n) = Tracks(n).Subsegvel;
                    else
                        vector{m}(n) = Tracks(n).Velocity;
                    end
                else
                    vector{m}(n) = nansum(data);
                end
        end
    end
end
x_vec = vector{1};
y_vec = vector{2};
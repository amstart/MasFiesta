function [x_vec, y_vec] = get_plot_vectors(Options, Tracks, xy)
vector = cell(1,2);
selected_vars = [Options.lPlot_XVar.val, Options.lPlot_YVar.val];
selected_methods = [Options.lMethod_TrackValue.val, Options.lMethod_TrackValueY.val];
for m = xy
    vector{m} = nan(length(Tracks),1);
    for n = 1:length(Tracks) % {'median', 'mean', 'end-start', 'minimum', 'maximum', 'standard dev', 'linear fit (only for velocity) or sum (only for MAP count)'}
        switch selected_methods(m)
            case 1
                vector{m}(n) = nanmedian(Tracks(n).Data(:,selected_vars(m)));
            case 2
                vector{m}(n) = nanmean(Tracks(n).Data(:,selected_vars(m)));
            case 3
                vector{m}(n) = Tracks(n).Data(end,selected_vars(m)) - Tracks(n).Data(1,selected_vars(m));
            case 4
                vector{m}(n) = min(Tracks(n).Data(:,selected_vars(m)));
            case 5
                vector{m}(n) = max(Tracks(n).Data(:,selected_vars(m)));
            case 6
                vector{m}(n) = nanstd(Tracks(n).Data(:,selected_vars(m)));
            case 7
                if selected_vars(m) == 3
                    vector{m}(n) = Tracks(n).Velocity;
                else
                    vector{m}(n) = nansum(Tracks(n).Data(:,selected_vars(m)));
                end
        end
    end
end
x_vec = vector{1};
y_vec = vector{2};
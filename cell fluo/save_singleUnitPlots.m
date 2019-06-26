function save_singleUnitPlots(figs,save_path)
for j = 1:numel(figs)
    savename = fullfile(save_path,figs(j).Name);
    print(figs(j),'-dpng',savename);    %Save PNG
    savefig(figs(j),savename);
end
close all;
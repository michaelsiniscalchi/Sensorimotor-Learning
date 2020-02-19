function figs = fig_validation_ITI( diff_ITIs, session_ID )

setup_figprops('timeseries');
figs = gobjects(numel(session_ID),1);

for i = 1:numel(figs)
    data = diff_ITIs{i}*1000; %Unit: ms -> s 
    max_err = max(abs(data)); 
    
    figs(i) = figure('Name',[session_ID{i} '_ITI_check [' num2str(int16(max_err)) ' ms]']);
    line(1:numel(data),data);
    xlabel('Trial number');
    ylabel('ITI_b_e_h - ITI_i_m_g (ms)');
    title([session_ID{i} ': ITI error']);

end
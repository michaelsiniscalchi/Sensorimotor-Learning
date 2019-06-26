%%% figs = plot_discrimSession
%
% PURPOSE:
% AUTHORS: MJ Siniscalchi
%
% INPUT ARGS:   
%
%--------------------------------------------------------------------------

function figs = plot_discrimSession( trialData, trials, time_range )

setup_figprop;  %Set up default figure plotting parameters
    
tlabel=strcat('Subject=',char(logData.subject),', Time=',char(logData.dateTime(1)),'-',char(logData.dateTime(2)));

    % Plot behavior in raw format
    plot_session_beh_vert(trialData,trials,blocks,tlabel,time_range);
    plot_session_beh_horz(trials,blocks,tlabel);

    
    % plot choice behavior (makes sense if performance is stable across entire session and no flexibility is involved)

        edges=[-3:0.1:7];   % edges to plot the lick rate histogram
        lick_trType=get_lickrate_byTrialType(trialData,trials,{'hit','err'},edges);

            plot_lickrate_byTrialType(lick_trType);
            plot_lickrate_overlay(lick_trType);
            plot_licknum_byTrialType(lick_trType);

        
        
        % save the analysis so can summarize the population results later
        save(fullfile(savematpath,'beh.mat'),...
            'choice_stat','lick_trType','numLick_missNext','numLick_respNext',...
            'numLick_missNext1','numLick_respNext1','numLick_missNext2','numLick_respNext2','-append');
    end
%%
    close all;
    clearvars -except i suppressFigs dirs expData data_subdir;
end

% plays sound when done
load train;
sound(y,Fs);

toc
clearvars files fList pList dependency_report*
files = {'import_nex_files_spikes_and_bursts.m','calculate_light_lick_responses.m','calc_spike_binned_data_remove_outliers.m','calc_perc_bursts_by_hour'}
dependency_report_out = {}
for f=1:length(files)
    dependency_report_out{1,f}=files{f};
    [fList, pList] = matlab.codetools.requiredFilesAndProducts(files{f})
    
    file_dependency = {};
    for i=1:length(fList)
        [path,name,ext] = fileparts(fList{i});
        dependency_report_out{3,f} = name
        file_dependency{i,2} = path
        file_dependency{i,1} = name
        file_dependency{i,3} = ext
    end
    dependency_report_out{2,f} = file_dependency;
    for i =1:length(file_dependency)
        dependency_report_out{2+i,f}=file_dependency{i}
    end

end
savefile='dependency_report.xlsx'
sz=[length(dependency_report_out),1];
info_cols=cell(sz);
info_cols{1,1}=['File Tested'];
for j =1:(length(info_cols)-2)
    info_cols{2+j,1}=sprintf('Required File #%d',j)
end

dependency_report_print=horzcat(info_cols,dependency_report_out)
xlswrite(savefile, dependency_report_print)

% for d=1:length(dependency_report_out)
%     [req_files] = dependency_report_out{2,d}{:,1}
% %     for r=1:length(req_files)
%     dependency_report_out{3:length(req_files),d} = req_files
% end
%         

% parts_list = {}
% for i=1:length(fList)
%     [path,name,ext] = fileparts(fList{i});
%     parts_list{i,1}=path;
%     parts_list{i,2}=name;
% end
% % exp = 'w:(\)\w*'
% % [tokens] = regexp(fList,exp,'tokens')
function [  ] = deltasq_many_files_CAMB_savefig( )

%(example) deltasq_many_files_CAMB_savefig();

% path_input_ps=strcat('../../CAMB/transfer_functions/');
% 
% files_list = dir(strcat(path_input_ps,'*.dat'));
% sorted_files_list={files_list.name};
% cd('../processing');
% sorted_files_list=sort_nat(sorted_files_list);

root='/home/asus/Dropbox/extras/storage/graham/small_res/';
root_out='/home/asus/Dropbox/extras/storage/graham/small_res/check/delta/';
spec='64Mpc_96c_48p_zi255_nowakem';
aux_path='/sample1001/';

cd('../preprocessing');


[~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec,aux_path );


path_CAMB='/home/asus/Dropbox/Disrael/Doutorado/Research/NBodyWake/production/CAMB/transfer_functions/';



for rds = 1 :  length(redshift_list)
    
    fig=figure('Visible', 'off');
%     filename=char(sorted_files_list(rds));
    filename_CAMB=strcat('camb_matterpower_z',char(redshift_list(rds)),'.dat');
    [ dat_input ] = import_( strcat(path_CAMB,filename_CAMB), '%f %f ',2 );
%     z = filename(28:end-4);
    

%form the dimensionless power spectrum

dat_input(:,2)=(1/(2*pi^2))*(dat_input(:,1).^3).*dat_input(:,2);

%semilogx(dat_input(:,1),dat_input(:,2),'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
loglog(dat_input(:,1),dat_input(:,2),'DisplayName',strcat('z = ',char(redshift_list(rds))),'LineWidth',2);


title(strcat('Dimensionless power spectrum from CAMB'),'interpreter', 'latex', 'fontsize', 20);
ylabel('$\Delta^2\ (k)$', 'interpreter', 'latex', 'fontsize', 20);
xlabel('$k (Mpc^{-1})$', 'interpreter', 'latex', 'fontsize', 20);
legend('show');

mkdir(path_CAMB,strcat('deltasq/'));
path_file_out=strcat(path_CAMB,'deltasq/','_',num2str(rds),'_delstasq_z',char(redshift_list(rds)),'.jpg');
saveas(fig,path_file_out);

end

cd('../../Analysis/power_spectrum');


end

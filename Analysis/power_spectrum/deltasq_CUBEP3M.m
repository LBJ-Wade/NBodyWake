function [  ] = deltasq_CUBEP3M( root,root_out,spec,aux_path,aux_path_out )

%(example) deltasq_CUBEP3M('/home/asus/Dropbox/extras/storage/graham/small_res/','/home/asus/Dropbox/extras/storage/graham/small_res/check/','64Mpc_96c_48p_zi255_nowakem','/sample1001/','' );

cd('../preprocessing');

[~,redshift_list,~,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec,aux_path );

path_output_delta=strcat(root,spec,aux_path);
files_list = dir(strcat(path_output_delta,'*new.dat'));
% sorted_files_list={files_list.name};
% cd('../processing');
% sorted_files_list=sort_nat(sorted_files_list);
% 
% cd('../preprocessing');

% for rds = 1 :  length(sorted_files_list)
for rds = 1 :  length(redshift_list)
    %for k = 1 : 1
    
    fig=figure('Visible', 'off');
    filename_CUBEP3M = strcat(char(redshift_list(rds)),'ngpps_new.dat');
%     filename=char(sorted_files_list(rds));
    dat_output = dlmread(strcat(path_output_delta,filename_CUBEP3M));
    %[ dat_output ] = import_( strcat(path_output_delta,filename), '%f %f %f $f $f',5 );
    z = char(redshift_list(rds));
    

%form the dimensionless power spectrum

%dat_input(:,2)=(1/(2*pi^2))*(dat_input(:,1).^3).*dat_input(:,2);

%semilogx(dat_input(:,1),dat_input(:,2),'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
loglog(dat_output(:,1),dat_output(:,2),'DisplayName',strcat('z = ',z),'LineWidth',2);


title({strcat('Dimensionless power spectrum'),strcat(' from the Nbody Simulation')},'interpreter', 'latex', 'fontsize', 20);
ylabel('$\Delta^2\ (k)$', 'interpreter', 'latex', 'fontsize', 20);
xlabel('$k (Mpc^{-1})$', 'interpreter', 'latex', 'fontsize', 20);
legend('show');


mkdir(root_out);
mkdir(root_out,strcat(spec,aux_path));

path_out=strcat(strcat(root_out,spec,aux_path),'plot/',aux_path_out,num2str(1),'lf_',num2str(1),'rf_',strcat(num2str(0),'-',num2str(0),'-',num2str(0)),'pv_',strcat(num2str(0),'-',num2str(0)),'ra','/','power_spectrum/delta_sq/');
mkdir(strcat(root_out,spec,aux_path),strcat('plot/',aux_path_out,num2str(1),'lf_',num2str(1),'rf_',strcat(num2str(0),'-',num2str(0),'-',num2str(0)),'pv_',strcat(num2str(0),'-',num2str(0)),'ra','/','power_spectrum/delta_sq/'));


path_file_out=strcat(path_out,'_',num2str(rds),'_deltasq_z',z,'.jpg');
saveas(fig,path_file_out);



end

cd('../power_spectrum');


end

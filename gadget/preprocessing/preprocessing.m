function [ xv_files_list,redshift_list,nodes_list  ] = preprocessing( path_files,spec_files,aux_path_files)
%   This function takes the path to the xv output of CUBEP3M and saves a list
%   with the filenames

%(example)[ xv_files_list,redshift_list,nodes_list ] = preprocessing('/home/asus/Dropbox/extras/storage/graham/small_res/','64Mpc_96c_48p_zi255_nowakem','/sample1001/');

%read xv files

 cd('../processing');

path_xv_files_in=strcat(path_files,spec_files,aux_path_files);
xv_files_list=dir(strcat(path_xv_files_in,'*xv*.dat'));
xv_files_list={xv_files_list.name};
xv_files_list=sort_nat(xv_files_list);

%write xv list

path_files_out=strcat(path_files,'data_list_out/',spec_files,aux_path_files);
mkdir(path_files_out);

fid=fopen(strcat(path_files_out,'xv_files_list.txt'),'w');
fprintf(fid,'%s\n',xv_files_list{:,:});
fclose(fid);

%how to read it:
% 
% file_list = fopen(strcat(path_files_out,'xv_files_list.txt'),'r');
% xv_files_list_z=textscan(file_list,'%s');
% xv_files_list_z=xv_files_list_z{1};
% xv_files_list_z=transpose(xv_files_list_z);
% fclose(file_list);


%write redshift list

redshift_list=dir(strcat(path_xv_files_in,'*xv0.dat'));
redshift_list={redshift_list.name};
redshift_list=sort_nat(redshift_list);
redshift_list=cellfun(@(x) x(1:end-7),redshift_list,'UniformOutput', false);
redshift_list=flip(redshift_list);

fid=fopen(strcat(path_files_out,'z_list.txt'),'w');
fprintf(fid,'%s\n',redshift_list{:,:});
fclose(fid);

%write nodes list

nodes_list=dir(strcat(path_xv_files_in,strcat(char(redshift_list(1)),'xv*.dat')));
nodes_list={nodes_list.name};
nodes_list=cellfun(@(x) x(3+length(char(redshift_list(1))):end-4),nodes_list,'UniformOutput', false);
nodes_list=sort_nat(nodes_list);

fid=fopen(strcat(path_files_out,'nodes_list.txt'),'w');
fprintf(fid,'%s\n',nodes_list{:,:});
fclose(fid);


 cd('../preprocessing');
 
 if (length(xv_files_list)==length(redshift_list)*length(nodes_list))
     display('the number of files is correct');
 else
     display('the number of files is incorrect');     
 end


end
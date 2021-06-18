function MDS_func(percentage_of_max, brem, npks, nplt)

	% does preprocessing (centering and scaling) on both datasets
	%
	% if nargins is one, it assumes that we're dealing with nonCat
	%
	% percentage_of_max --> lowest percenteage of the max eigenvalue 
	%                       that an eigenvalue can have and still be 
	%                       assumed to correspond to a latent variable
	%
	% brem --> either empty or indicates brem presence (true, false)
	% npks --> either empty or indicates the number of peaks
	% nplt --> either empty or indicates the number of plateuas

	b2b_fname_in = '';
	one_fname_in = '';

	b2b_fname_out = '';
	one_fname_out = '';

	switch nargin
		case 1 % file without categorization
			
			b2b_fname_in = 'b2b_sans_preprocessed_SFFS.xlsx';
			one_fname_in = 'one_sans_preprocessed_SFFS.xlsx';
			
			b2b_fname_out = 'b2b_sans_MDS.xlsx';
			one_fname_out = 'one_sans_MDS.xlsx';
			
		case 4 % file with categorization
			
			brem_str = 'N';
			if brem
				brem_str = 'Y';
			end
			
			npks_str = num2str(npks);
			if npks > 2
				npks_str = 'M';
			end
			
			nplt_str = num2str(nplt);
			if nplt > 2
				nplt_str = 'M';
			end
			
			b2b_fname_in = ['0vbb_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed_SFFS.xlsx'];
			
			one_fname_in = ['1e_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed_SFFS.xlsx'];
			
			b2b_fname_out = ['0vbb_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_MDS.xlsx'];
			
			one_fname_out = ['1e_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_MDS.xlsx'];
			
		otherwise
		
			error('incorrect number of arguments')
	end
	
	opts_b2b_in = detectImportOptions(b2b_fname_in);
	b2b_M_in = readmatrix(b2b_fname_in);
	b2b_M_in_sz = size(b2b_M_in);
	b2b_in_cols = num2cell(1:length(opts_b2b_in.VariableNames));
	b2b_in_colNames_cell = [b2b_in_cols' (opts_b2b_in.VariableNames)'];

	opts_one_in = detectImportOptions(one_fname_in);
	one_M_in = readmatrix(one_fname_in);
	one_M_in_sz = size(one_M_in);
	one_in_cols = num2cell(1:length(opts_one_in.VariableNames));
	one_in_colNames_cell = [one_in_cols' (opts_one_in.VariableNames)'];

	Y_M = (cat(1,b2b_M_in, one_M_in))';

	S = Y_M' * Y_M;
	[U,LAM] = eig(S);
	[d,ind] = sort(diag(-LAM));
	LAM_sort = LAM(ind,ind);
	U_sort = U(:,ind);   
   
    eivals = (-d).^0.5;
	eimax = eivals(1);
                  
    P = find(eivals < percentage_of_max * eimax / 100 , ... 
             1, 'first');
	
	Y_M_sz = size(Y_M);
	N = Y_M_sz(2);

	I_P_N = cat( 2, eye(P), zeros(P, N - P) );

	X_M = (I_P_N * LAM_sort.^0.5 * U_sort')'; % this didn't have sqrt here.
                                                        % maybe that's what was ruining the
                                                        % results?
    % W_M = (Y_M * U_sort * (LAM_sort.^-0.5) * I_P_N_corr')';
                          
	b2b_latent = X_M(1:b2b_M_in_sz(1),:);
	one_latent = X_M(b2b_M_in_sz(1)+1:end,:);

	latent_col_names = {};

	for i = 1:P
    
    	latent_col_names{i,1} = ['latent' num2str(i)];
	end

	b2b_T = array2table(b2b_latent, ...
	                    'VariableNames',latent_col_names);
	one_T = array2table(one_latent, ...
	                    'VariableNames',latent_col_names);

	writetable(b2b_T, b2b_fname_out, 'Sheet', 1, 'Range', 'A1');
	writetable(one_T, one_fname_out, 'Sheet', 1, 'Range', 'A1');      
                                         
end

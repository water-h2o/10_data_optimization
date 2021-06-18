function featureCalibration_func(brem, npks, nplt)

	% does preprocessing (centering and scaling) on both datasets
	%
	% if nargins is zero, it assumes that we're dealing with nonCat
	% brem --> either empty or indicates brem presence (true, false)
	% npks --> either empty or indicates the number of peaks
	% nplt --> either empty or indicates the number of plateuas

	b2b_fname_in = '';
	one_fname_in = '';

	b2b_fname_out = '';
	one_fname_out = '';

	switch nargin
		case 0 % file without categorization
			
			b2b_fname_in = '../../b2bFF_sansCategories.xlsx';
			one_fname_in = '../../1eFF_sansCategories.xlsx';
			
			b2b_fname_out = 'b2b_sans_preprocessed.xlsx';
			one_fname_out = 'one_sans_preprocessed.xlsx';
			
		case 3 % file with categorization
			
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
			
			b2b_fname_in = ['../../0vbb_'    ...
			                brem_str '_' ...
			                npks_str '_'   ...
			                nplt_str '.xlsx'];
			
			one_fname_in = ['../../1e_'    ...
			                brem_str '_' ...
			                npks_str '_'   ...
			                nplt_str '.xlsx'];
			
			b2b_fname_out = ['0vbb_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed.xlsx'];
			
			one_fname_out = ['1e_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed.xlsx'];
			
		otherwise
		
			error('incorrect number of arguments')
	end

	opts_b2b = detectImportOptions(b2b_fname_in);
	b2b_M    = readmatrix(b2b_fname_in);
	b2b_M_sz = size(b2b_M);

	opts_one = detectImportOptions(one_fname_in);
	one_M    = readmatrix(one_fname_in);
	one_M_sz = size(one_M);

	%% average

	Y_T_M = cat(1,b2b_M,one_M);

	b2b_means_M = repmat(mean(Y_T_M,1),b2b_M_sz(1),1);
	one_means_M = repmat(mean(Y_T_M,1),one_M_sz(1),1);

	b2b_M_norm = b2b_M - b2b_means_M;
	one_M_norm = one_M - one_means_M;

	%% standard deviation

	b2b_stdev_M = repmat(std(Y_T_M,1),b2b_M_sz(1),1);
	one_stdev_M = repmat(std(Y_T_M,1),one_M_sz(1),1);

	b2b_M_preprocessed = b2b_M_norm ./ b2b_stdev_M;
	one_M_preprocessed = one_M_norm ./ one_stdev_M;
	
	b2b_T = array2table(b2b_M_preprocessed(:,2:end), ...
                   'VariableNames', opts_b2b.VariableNames(2:end));
	one_T = array2table(one_M_preprocessed(:,2:end), ...
                   'VariableNames', opts_one.VariableNames(2:end));

	writetable(b2b_T,b2b_fname_out,'Sheet',1,'Range','A1');
	writetable(one_T,one_fname_out,'Sheet',1,'Range','A1');
end

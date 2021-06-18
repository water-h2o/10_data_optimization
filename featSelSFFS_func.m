function featSelSFFS_func(brem, npks, nplt)

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
			
			b2b_fname_in = 'b2b_sans_preprocessed.xlsx';
			one_fname_in = 'one_sans_preprocessed.xlsx';
			
			b2b_fname_out = 'b2b_sans_preprocessed_SFFS.xlsx';
			one_fname_out = 'one_sans_preprocessed_SFFS.xlsx';
			
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
			
			b2b_fname_in = ['0vbb_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed.xlsx'];
			
			one_fname_in = ['1e_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed.xlsx'];
			
			b2b_fname_out = ['0vbb_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed_SFFS.xlsx'];
			
			one_fname_out = ['1e_' ... 
			                 brem_str '_' ...
			                 npks_str '_' ...
			                 nplt_str '_preprocessed_SFFS.xlsx'];
			
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

	cov_b2b_in = cov(b2b_M_in)*((b2b_M_in_sz(1) -1) / b2b_M_in_sz(1));
	cov_one_in = cov(one_M_in)*((one_M_in_sz(1) -1) / one_M_in_sz(1));
	cov_common_in = 0.5.*(cov_b2b_in+cov_one_in);

	[min_per_col, row] = min(abs(cov_common_in));
	[dont_care, col]   = min(abs(min_per_col));

	row = row(col);

	b2b_M_out = cat(2,b2b_M_in(:,col),b2b_M_in(:,row));
	one_M_out = cat(2,one_M_in(:,col),one_M_in(:,row));
	out_colNames_cell = [b2b_in_colNames_cell(row,:) ; ... 
		                 b2b_in_colNames_cell(col,:)];

	%% SFFS

	theyreTheSame = false;
	b2b_M_out_test = b2b_M_out;
	one_M_out_test = one_M_out;

	passes = 0;

	while theyreTheSame == false
		
		passes = passes +1;
		
		disp([' '])
		disp(['-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -'])
		disp(['SFFS pass #' num2str(passes)])
		
		%% step 1. inclusion
		
		legal_cols = setdiff(cell2mat(one_in_colNames_cell(:,1)), ...
		                     cell2mat(out_colNames_cell(:,1)));
		
		Js = zeros(1,length(legal_cols));
		                 
		for i = 1:length(legal_cols)
		                 
		    Js(i) = myMahal(cat(2,b2b_M_out,b2b_M_in(:,i)), ...
		                    cat(2,one_M_out,one_M_in(:,i)));
		
		end      
		
		Js(isnan(Js-isinf(Js).*Js)) = 0; % remove NaNs and Infs
		
		[J1, max_idx] = max(Js);
		
		disp(['J1 = ' num2str(J1)])
		
		b2b_M_out_test = cat(2, b2b_M_out, ...
		                     b2b_M_in(:, legal_cols(max_idx)));
		one_M_out_test = cat(2, one_M_out, ...
		                     one_M_in(:, legal_cols(max_idx)));
		
		disp(['step 1: added ' ...
		          b2b_in_colNames_cell(legal_cols(max_idx),2)])
		
		out_colNames_cell=[out_colNames_cell ; ...
		                   b2b_in_colNames_cell(legal_cols(max_idx),:)];
		
		%% step 2. conditional exclusion
		
		o_cN_c_sz = size(out_colNames_cell);
		
		Js = zeros(1,o_cN_c_sz(1));
		
		for i = 1:o_cN_c_sz(1)
		
		    Js(i) = myMahal(exceptOneColumn(b2b_M_out_test,i), ...
		                    exceptOneColumn(one_M_out_test,i));         
		end
		
		Js(isnan(Js-isinf(Js).*Js)) = 0; % remove NaNs and Infs
		
		[J2, max_idx] = max(Js);
		
		disp(['J2 = ' num2str(J2)])
		
		if J2 > J1
		    
		    disp(['step 2: removed ' ...
		          out_colNames_cell(max_idx,2)])
		    
		    b2b_M_out_test(:,max_idx)    = [];
		    one_M_out_test(:,max_idx)    = [];
		    out_colNames_cell(max_idx,:) = [];
		end
		                 
		%% check and finish
		
		if isequal(b2b_M_out_test, b2b_M_out) == true
		    
		    theyreTheSame = true;
		end
		
		b2b_M_out = b2b_M_out_test;
		one_M_out = one_M_out_test;
		
		disp(['number of features = ' ...
		      num2str(length(cell2mat(out_colNames_cell(:,1))))])
		disp(['features selected for pass #' num2str(passes) ':'])
		disp(out_colNames_cell(:,2))
		
	end

	%% write to file

	file_colNames_cell = sortrows(out_colNames_cell);

	f_cN_c_sz = size(file_colNames_cell);

	b2b_M_file = b2b_M_in(:,file_colNames_cell{1,1});
	one_M_file = one_M_in(:,file_colNames_cell{1,1});

	for i = 2:f_cN_c_sz(1)
	   
		b2b_M_file = cat(2, b2b_M_file, ...
		                 b2b_M_in(:,file_colNames_cell{i,1}));
		one_M_file = cat(2, one_M_file, ...
		                 one_M_in(:,file_colNames_cell{i,1}));
	end

	b2b_T = array2table(b2b_M_file, 'VariableNames', ...
	                    file_colNames_cell(:,2));
	one_T = array2table(one_M_file, 'VariableNames', ...
	                    file_colNames_cell(:,2));

	writetable(b2b_T,b2b_fname_out,'Sheet',1,'Range','A1');
	writetable(one_T,one_fname_out,'Sheet',1,'Range','A1');
end

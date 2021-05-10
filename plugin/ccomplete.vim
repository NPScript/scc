let s:c_completer_executable = expand('<sfile>')
let s:c_completer_executable = strpart(s:c_completer_executable, 0, strridx(s:c_completer_executable, "/"))
let s:c_completer_executable = strpart(s:c_completer_executable, 0, strridx(s:c_completer_executable, "/"))
let s:c_completer_executable = s:c_completer_executable . "/c_completer"

function! GetFunComplete(base)
		let functions=split(system(s:c_completer_executable . " fun " . expand("%") . " 2>/dev/null | grep '" . a:base . "'"), '\n')
		let items = []
		for f in functions
			let fs = split(f, "\|")
			let name = fs[1]
			let rettype = fs[0]
			call add(items, {"word" : name, "menu" : "-> " . rettype, "kind": "f"})
		endfor

		return items
endfunction

function! GetVarComplete(base)
		let functions=split(system(s:c_completer_executable . " var " . expand("%") . " 2>/dev/null | grep '" . a:base . "'"), '\n')
		let items = []
		for f in functions
			let fs = split(f, "\|")
			let name = fs[1]
			let rettype = fs[0]
			call add(items, {"word" : name, "menu" : ": " . rettype, "kind": "v"})
		endfor

		return items
endfunction

function! GetDefComplete(base)
		let functions=split(system(s:c_completer_executable . " def " . expand("%") . " 2>/dev/null | grep '" . a:base . "'"), '\n')
		let items = []
		for f in functions
			let fs = split(f)
			let name = join(fs[1:], " ")
			let rettype = fs[0]
			call add(items, {"word" : name, "kind": "d"})
		endfor

		return items
endfunction

function! Ccomplete(findstart, base)
	if a:findstart
		normal b
		return col('.') - 1
	else
		let items = GetFunComplete(a:base)
		let items = items + GetVarComplete(a:base)
		let items = items + GetDefComplete(a:base)

		return items
	endif
endfunction

function! CSelectNextArgument()
	let distance = 0
	let lastpos = 0
	if search("(", "zWp", line('.'))
		let lastpos = col('.')
	else
		if search(",", "zWp", line('.'))
			let lastpos = col('.')
		else
			startinsert!
			return
		endif
	endif

	if search(",", "zWp", line('.'))
		let distance = col('.') - lastpos - 2
	else
		call search(")", "zWp", line('.'))
		let distance = col('.') - lastpos - 2
	endif

	if distance > 0
		execute "normal! hv" . distance . "ho"
	endif
endfunction

autocmd FileType c command! CSelNextArg call CSelectNextArgument()
autocmd FileType c nnoremap <tab> :CSelNextArg<CR>
autocmd FileType c vnoremap <tab> <esc>:CSelNextArg<CR>
autocmd FileType c inoremap <silent><expr> <return> pumvisible() ? "\<C-Y>\<esc>0:CSelNextArg\<CR>" : "\<return>"
autocmd FileType c inoremap <silent><expr> <tab> pumvisible() ? "\<C-N>" : "\<tab>"
autocmd FileType c inoremap <silent><expr> <s-tab> pumvisible() ? "\<C-P>" : "\<s-tab>"
autocmd FileType c inoremap <silent> <C-S> <C-X><C-U>

autocmd FileType c setlocal completefunc=Ccomplete

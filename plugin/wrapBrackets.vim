" {{ grab the filetype
let s:filetype = &filetype
" }}

" If this plugin is active then it complicates things -> EDIT: not really
let s:exists_wrap_brackets = exists('g:AutoPairsLoaded')

" {{ Defaults
" mappings for different languages
let g:print_mappings = get(g:, 'print_mappings', 
            \ {
            \ "python": "print", 
            \ "javascript.jsx": "console.log", 
            \ "typescript": "console.log", 
            \ "vim": "echomsg string", 
            \ "cpp": "std::cout",
            \ "java": "System.out.println"
            \ })
" the desired brackets for each language
" cpp brackets require more than one character for opening and closing
" brackets, so an array is used to store the opening and closing 'parentheses'
let g:brackets = get(g:, "brackets", 
            \ {"python": "()", 
            \ "javascript.jsx": "():", 
            \ "typescript": "();", 
            \ "vim": "()", 
            \ "cpp": [" << ", ' << "\n";'],
            \ "java": "();"
            \ })
" if you have a variable in between quotes, or angled brackets, these mappings
" will make sure not to grab the quote
let g:before_wrappings = get(g:, 'before_wrappings', ["\"", "\'", '>', '<'])
" If 1: copies the variable and inserts the print statement above
" If 0: wraps the word with the print statement only
let g:keep_copy = get(g:, 'keep_copy', 1)
let g:wrap_mapping = get(g:, 'wrap_mapping', "<c-q>")
" }}

" {{ Helper Function to grab the visual selection CREDIT: https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! VisualSelection()
    if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ''
    endif
    let lines[-1] = lines[-1][: column_end - 1]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction
" }}

function! GetIndent() abort
    return indent('.')
endfunction

" {{ Main function that performs the wrapping 
function! Wrap(mode, extra) abort
    " disabled the plugin autopairs if it exists
    let s:ap_enabled = 0
    if s:exists_wrap_brackets
        if b:autopairs_enabled
            let s:ap_enabled = 1
            call AutoPairsToggle()
        endif
    endif

    let s:printer = g:print_mappings[&filetype]
    let s:line_indent = GetIndent()
    if a:mode == 0
        if a:extra
            exe "norm! yiwO"
        else
            exe "norm! yiwdiw"
        endif
        let s:char_on = index(g:before_wrappings, matchstr(getline('.'), '\%' . col('.') . 'c.'))
        let s:char_before = strcharpart(strpart(getline('.'), col('.') - 1), 0, 1)
        if col(".") == 1
            exe "norm! i" . repeat(" ", s:line_indent) . s:printer . g:brackets[&filetype][0]
            exe "norm! pa" . g:brackets[&filetype][1]
        elseif s:char_on != -1 || s:char_before != -1
            exe "norm! i" . repeat(" ", s:line_indent) . s:printer . g:brackets[&filetype][0]
            exe "norm! pa" . g:brackets[&filetype][1]
		else
			exe "norm! i " . repeat(" ", s:line_indent) . s:printer . g:brackets[&filetype][0]
            exe "norm! pa" . g:brackets[&filetype][1]
        endif
        "exe "norm! hp"
    elseif a:mode == 1
        let s:selection = VisualSelection()
        let s:char_on = index(g:before_wrappings, matchstr(getline('.'), '\%' . col('.') . 'c.'))
        let s:char_before = strcharpart(strpart(getline('.'), col('.') - 1), 0, 1)
        exe "norm! O"
        if col('.') == 1
            exe "norm! i" . repeat(" ", s:line_indent) . s:printer . g:brackets[&filetype][0] . s:selection . g:brackets[&filetype][1]
        elseif s:char_on != -1 || s:char_before != -1
            exe "norm! i" . repeat(" ", s:line_indent) . s:printer . g:brackets[&filetype][0] . s:selection . g:brackets[&filetype][1]
        else
            exe "norm! i " . repeat(" ", s:line_indent) . s:printer . g:brackets[&filetype][0] . s:selection . g:brackets[&filetype][1]    
        endif
        "exe "norm! ha" . s:selection
    endif

    " re-enable if it exists and was previously enabled
    if s:exists_wrap_brackets
        if !b:autopairs_enabled && s:ap_enabled
            call AutoPairsToggle()
        endif
    endif
endfunction
" }}

execute "nnoremap " . g:wrap_mapping . " :call Wrap(0," . g:keep_copy .  ")<Enter>"
execute "xnoremap " . g:wrap_mapping . " :call Wrap(1," . g:keep_copy .  ")<Enter>"

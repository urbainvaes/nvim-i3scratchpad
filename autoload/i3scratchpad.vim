let s:floating_buffers = []

function! s:remove_floating(bufnr)
    let index = index(s:floating_buffers, a:bufnr)
    call remove(s:floating_buffers, index)
endfunction

function! s:focus_floating(bufnr)
    let [offsetx, offsety] = [0, 1]  " Tabline
    let [cutoffx, cutoffy] = [0, 1 + &cmdheight]  " Statusline and Cmdline
    let [sizex, sizey] = [&columns - offsetx - cutoffx, &lines - offsety - cutoffy]
    let percent_margins = 10
    let [marginx, marginy] = [(percent_margins*sizex)/100, (percent_margins*sizey)/100]
    let kwargs = {'relative': 'editor',
                \ 'row': offsety + marginy, 'col': offsetx + marginx,
                \ 'width': sizex - 2*marginx, 'height': sizey - 2*marginy}
    call nvim_open_win(a:bufnr, 1, kwargs)
    exe "autocmd! WinClosed ".win_getid()." call s:remove_floating(".a:bufnr.")"
endfunction

function! i3scratchpad#toggle_scratchpad()
    let [winnr, bufnr] = [winnr(),  bufnr()]
    let is_floating = nvim_win_get_config(0)['relative'] != ''
    silent! exe winnr."wincmd c"
    if is_floating
        exe "vert sbuffer ".bufnr
    else
        call s:focus_floating(bufnr)
        call add(s:floating_buffers, bufnr)
    endif
endfunction

function! i3scratchpad#cycle_scratchpads()
    " Check if there is a floating window in the current tab
    let floating_exists = 0
    let wins = nvim_tabpage_list_wins(0)
    for win in wins
        let win_is_floating = nvim_win_get_config(win)['relative'] != ''
        if win_is_floating
            let floating_exists = 1
            let bufnr = winbufnr(0)
            exe nvim_win_get_number(win)."wincmd c"
            call add(s:floating_buffers, bufnr)
        endif
    endfor
    if !floating_exists && !empty(s:floating_buffers)
        let bufnr = s:floating_buffers[0]
        call s:focus_floating(bufnr)
        call remove(s:floating_buffers, 0)
        call add(s:floating_buffers, bufnr)
    endif
endfunction

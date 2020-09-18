" The MIT License (MIT)
"
" Copyright (c) 2020 Urbain Vaes
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

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

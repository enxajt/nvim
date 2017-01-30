
"---------------------------------------------------------------
" vi互換モード禁止
" 各種プラグイン等機能しなくなったりするため
"
if &compatible
   set nocompatible               " Be iMproved
endif

"---------------------------------------------------------------
" コンソール版で環境変数$DISPLAY
" が設定されていると起動が遅くなる件へ対応
"
if !has('gui_running') && has('xterm_clipboard')
  set clipboard=exclude:cons\\\|linux\\\|cygwin\\\|rxvt\\\|screen
endif

"---------------------------------------------------------------
" win,mac対応
"
" WinではPATHに$VIMが含まれていないときにexeを見つけ出せないので修正
if has('win32') && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
  let $PATH = $VIM . ';' . $PATH
endif

if has('mac')
  " Macではデフォルトの'iskeyword'がcp932に対応しきれていないので修正
  set iskeyword=@,48-57,_,128-167,224-235
endif

"---------------------------------------------------------------
" file, directly 
let $VIMDIR = $HOME."/.vim"
"=の前後にスペースは入れない
let &backupdir=$VIMDIR."/backup" 
let &directory=$VIMDIR."/swp" 
let &undodir=$VIMDIR."/undo"
"let &dictionary=$VIMDIR."/dict/kotani.dicts" 

"---------------------------------------------------------------
" file(encode, format)
"
" 改行コードの自動認識
set fileformats=dos,unix,mac

" textwidthでフォーマットさせたくない
set formatoptions=q

"---------------------------------------------------------------
" file(文字コードの自動認識)
"
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif

"---------------------------------------------------------------
" file(md, coffee)
"
let g:vim_markdown_folding_disabled = 1
"let g:vim_markdown_folding_level = 6

".mdファイルもMarkdown記法として読み込む
au BufRead,BufNewFile *.md set filetype=markdown

au BufRead,BufNewFile *.coffee set filetype=javascript


"---------------------------------------------------------------
" file(ファイル名の大文字小文字)
" ファイル名に大文字小文字の区別がないシステム用(例: DOS/Windows/MacOS)
"
if filereadable($VIM . '/vimrc') && filereadable($VIM . '/ViMrC')
  " tagsファイルの重複防止
  set tags=./tags,tags
endif

"if has('path_extra')
"    set tags& tags + =.tags, tags
"endif

"---------------------------------------------------------------
" view 
"
" バッファを保存しなくても他のバッファを表示できるようにする
 set hidden 

"起動時のメッセージなし
set shortmess+=I

" 行番号を表示
set number

" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch

" □とか○の文字があってもカーソル位置がずれないようにする
" ただし、éàèなどが全角になる
"if exists('&ambiwidth')
"  set ambiwidth=double
"endif

" Use visual bell instead of beeping when doing something wrong
set visualbell
" vim will neither flash nor beep.  If visualbell
set t_vb=

"---------------------------------------------------------------
" view (tab, eol)
"
" タブや改行を表示 (list or nolist)
" "tab:>-" とすると、タブが4文字の設定では ">---" となる。
"      指定されないと、タブは ^I と表示される。
" trail:文字	行末の空白の表示に使われる文字。
" 文字 ':' と ',' は使えない。
set list
set listchars=tab:>-,trail:.,eol:↲,nbsp:%

" " 'Yggdroot/indentLine'
" "let g:indentLine_faster = 1
" let g:indentLine_leadingSpaceEnabled = 1
" let g:indentLine_leadingSpaceChar = '.'
" "nmap <silent><Leader>i :<C-u>IndentLinesToggle<CR>

" 折り返しマーク
"set showbreak=

" 勝手に改行するのをやめる
" set textwidth=0    " 日本語入力時には効かなかった
 
" 長い行を折り返して表示 (nowrap:折り返さない)
set wrap

"---------------------------------------------------------------
" view (tab)
"
" タブをスペースに展開
" 本当のタブ文字を挿入したい場合は <C-v><Tab>
set expandtab

" タブを、画面上の見た目で何文字分に展開するか
set tabstop=2
"set tabstop=4
" softtabstopが0の場合は、tsを4に設定しても、softtabstop分だけ
" softtabstopが0の場合はtsで指定した分
set softtabstop=0

"vimが挿入('cindent')や(>>や<<)、autoindent時に挿入/削除されるインデントの幅が画面上の見た目で何文字分か
set shiftwidth=2
"set shiftwidth=4

" Tab 入力時 ↓ 
" 行頭の余白内で 'shiftwidth' の数だけインデント
" 行頭以外では 'tabstop' の数だけ空白が挿入
" オフのときは、常に 'tabstop' の数だけインデント
set smarttab

"---------------------------------------------------------------
" view (highlight) 
"
"全角スペースをハイライト表示
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=grey gui=reverse guifg=DarksLateGray
endfunction
"darkgrey 文字色っぽい
"dimgrey 文字色っぽい
"DarksLateGray 緑っぽい
if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme       * call ZenkakuSpace()
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif

"---------------------------------------------------------------
" view (command)
"
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
set wildmode=list:full
set wildignore=*.o,*.obj,*.pyc,*.so,*.dll
let g:python_highlight_all = 1

" Show partial commands in the last line of the screen
" タイプ途中のコマンドを画面最下行に表示
set showcmd

" コマンドラインの高さ (Windows用gvim使用時はgvimrcを編集すること)
set cmdheight=2

" show window title
"set title

"---------------------------------------------------------------
" view (status)
"
"ステータス行を表示
set laststatus=2

" %< - 行が長すぎるときに切り詰める位置
" %f - ファイル名(相対パス), %F - (絶対パス), %t - (パス無し)
" %m - 修正フラグ （[+]または[-]）
" %r - 読み込み専用フラグ（[RO]）
" %h - ヘルプバッファ
" %w - preview window flag
"set statusline=%<%f\ %m%r%h%w
set statusline=%<%f\ %m\ %r%h%w

set statusline+=%{'['.(&fenc!=''?&fenc:&enc).']['.&fileformat.']'}

" %= - 左寄せと右寄せ項目の区切り（続くアイテムを右寄せにする）
set statusline+=%=

"if has('win32')
"  set statusline+=%{anzu#search_status()}
"endif

" "set ruler" (~行目の,~文字目 ~~%) 代わり
" %l - 現在のカーソルの行番号, %L - 総行数
" %c - column番号
" %V - カラム番号
" %P - カーソルの場所 %表示
set statusline+=%4l/%L,%c%V%4P

"---------------------------------------------------------------
" view (color) 
"

"colorschemeコマンドを実行する前に設定する
set t_co=256

set virtualedit=block
if has('nvim')
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

" 画面を黒地に白にする (次行の先頭の " を削除すれば有効になる)
set background=dark
"colorscheme hybrid " (Windows用gvim使用時はgvimrcを編集すること)

function! s:load_after_colors()
  let color = expand($VIMDIR.'/colors/color_enxajt.vim')
  if filereadable(color)
    execute 'source ' color
  endif
endfunction
augroup MyColors
  autocmd!
  autocmd ColorScheme * call s:load_after_colors()
augroup END

" 編集行のハイライト
"set cursorline
" cursorlineの色をクリア
hi clear CursorLine

"---------------------------------------------------------------
" view (コンソールでのカラー表示)
"(暫定的にUNIX専用)
if has('unix') && !has('gui_running')
  let s:uname = system('uname')
  if s:uname =~? "linux"
"   set term=builtin_linux
"   set term=xterm
    let &t_ab="\e[48;5;%dm"
    let &t_af="\e[38;5;%dm"
  elseif s:uname =~? "freebsd"
    set term=builtin_cons25
  elseif s:uname =~? "darwin"
"    set term=beos-ansi
"    set term=builtin_ansi
  else
    set term=builtin_xterm
  endif
  unlet s:uname
endif

"---------------------------------------------------------------
" move
"
"カーソルを表示行で移動する。物理行移動は<c-n>,<c-p>
nmap j gj
nmap k gk
nmap <down> gj
nmap <up>   gk

" 入力モードでのカーソル移動 ctrl+shift+j と干渉
"inoremap <c-j> <down>
"inoremap <c-k> <up>
"inoremap <c-h> <left>
"inoremap <c-l> <right>

 " stop certain movements from always going to the first character of a line.
 " while this behaviour deviates from that of vi, it does what most users
 " coming from other editors would expect.
 " 移動コマンドを使ったとき、行頭に移動しない
 set nostartofline

 " instead of failing a command because of unsaved changes, instead raise a
 " dialogue asking if you wish to save changed files.
 " バッファが変更されているとき、コマンドをエラーにするのでなく、保存する
 " かどうか確認を求める
 set confirm

" auto save
set autowrite
set updatetime=1000
function! s:autowriteifpossible()
  if &modified && !&readonly && bufname('%') !=# '' && &buftype ==# '' && expand("%") !=# ''
    write
  endif
endfunction
augroup autowrite
  autocmd!
  autocmd cursorhold * call s:autowriteifpossible()
  autocmd cursorholdi * call s:autowriteifpossible()
augroup end

" enable use of the mouse for all modes
"set mouse=a

"---------------------------------------------------------------
" search
"
set incsearch

" 検索時に大文字小文字を無視 (noignorecase:無視しない)
set ignorecase

" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase

" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set wrapscan

" 検索語を強調表示
set hlsearch

"\v(very magic) vim方言を使わずに、一般的な正規表現に近い形で書ける
":help magic
" nmap / /\v
" nmap ? ?\v

" if has('win32')
"   map /  <plug>(incsearch-forward)
"   map ?  <plug>(incsearch-backward)
"   map g/ <plug>(incsearch-stay)
" endif

" 検索語が画面の真ん中に来るようにする
"nmap n nzz
""nmap n nzz "逆方向検索できなくなる  
"nmap * *zz 
"nmap # #zz 
"nmap g* g*zz 
"nmap g# g#zz

" "---------------------------------------------------------------
" " search (osyo-manga/vim-anzu)
" "
" nmap n <plug>(anzu-n-with-echo)zz
" nmap n <plug>(anzu-n-with-echo)zz
" nmap * <plug>(anzu-star-with-echo)
" nmap # <plug>(anzu-sharp-with-echo)zz
" nmap <esc><esc> <plug>(anzu-clear-search-status)
" 
" " if start anzu-mode key mapping
" " anzu-mode is anzu(12/51) in screen
" " nmap n <plug>(anzu-mode-n)
" " nmap n <plug>(anzu-mode-n)

"---------------------------------------------------------------
" edit
"
" インデントや改行,挿入モード直後をバックスペース可能
set backspace=indent,eol,start

"---------------------------------------------------------------
" edit (indent)
"
" 自動的にインデントする (noautoindent:インデントしない)
set autoindent
"新しい行を作ったときに高度な自動インデントを行う
set smartindent

" テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions+=mm

"---------------------------------------------------------------
" yank 
"
" ビジュアル選択(d&d他)を自動的にクリップボードへ (:help guioptions_a)
"set guioptions+=a

"通常は無名レジスタに入るヤンク/カットが、*レジスタにも入るようになる
"*レジスタにデータを入れると、クリップボードにデータが入る
set clipboard+=unnamed

" capture
if !has('win32')
  command!
      \ -nargs=1
      \ -complete=command
      \ capture
      \ call Capture(<f-args>)
endif
function! Capture(cmd)
  redir => result
  silent execute a:cmd
  redir end

  let bufname = 'capture: ' . a:cmd
  new
  setlocal bufhidden=unload
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal noswapfile
  silent file `=bufname`
  silent put =result
  1,2delete _
endfunction

"---------------------------------------------------------------
" neobundle 2016/3/11
"
let s:neo_enabled  = 0
if v:version < 704 || has('win64')
  let s:neo_enabled = 1

" install to windows
" mkdir $vim\bundle
" git clone https://github.com/shougo/neobundle.vim bundle\neobundle.vim
 
  " vim起動時のみruntimepathにneobundle.vimを追加
  if has('vim_starting')
    if &compatible
        set compatible
    endif
    set runtimepath+=$vim/bundle/neobundle.vim/
  endif
  
  " neobundle.vimの初期化 " neobundleを更新するための設定
call neobundle#begin(expand($vim.'/bundle'))
  neobundlefetch 'shougo/neobundle.vim'
  
"  " :h markdown-cheat-sheet
"  neobundle 'gist:hail2u/747628', {
"         \ 'name': 'markdown-cheat-sheet.jax',
"         \ 'script_type': 'doc'}
"  neobundle 'junegunn/vim-easy-align'
"  neobundle 'kannokanno/previm'
"  neobundle 'shougo/vimfiler.vim'
"  neobundle 'tyru/open-browser.vim'
"let g:netrw_nogx = 1
"nmap gs <plug>(openbrowser-smart-search)
"vmap gs <plug>(openbrowser-smart-search)
"command! openbrowsercurrent execute "openbrowser" "file:///".expand("%:p")
"
"  " search
"  neobundle 'haya14busa/incsearch.vim'
"  neobundle 'osyo-manga/vim-anzu'
"
"  " syntax, color, indent
"  neobundle 'hail2u/vim-css3-syntax'
"  neobundle 'othree/html5.vim'
   neobundle 'plasticboy/vim-markdown'
"  neobundle 'w0ng/vim-hybrid'
   neobundle 'yggdroot/indentline'
"  neobundle 'vimperator/vimperator'
  
"  javascript syntax hilight
  neobundle 'pangloss/vim-javascript'
  neobundle 'othree/yajs.vim'

  " pluntumlのシンタクスハイライトと:makeコマンド
  " *.pu か *.uml か *.plantuml 
  "neobundle 'aklt/plantuml-syntax'
  "letg:plantuml_executable_script = "~/dotfiles/plantuml"
  "neobundle 'vim-scripts/plantuml-syntax'

  " unite
  neobundle 'sgur/unite-everything'
  neobundle 'shougo/neomru.vim'
  neobundle 'shougo/unite.vim'
  neobundle 'shougo/neoyank.vim'
  neobundle 'shougo/unite-outline'

  " sugest
  " neocompleteは、neovimでdeopleteに移行
  neobundle 'shougo/neocomplete.vim'
  neobundle 'shougo/neco-syntax'
  neobundle 'shougo/neosnippet'
  neobundle 'shougo/neosnippet-snippets'

"  " autocompletion python
"  "neobundle 'davidhalter/jedi-vim'
"  "jedi-vimにはclang_completeが必要
"  "neobundle 'git://github.com/shougo/clang_complete.git'
"  
"  "markdownとかで他の言語が埋め込まれてる時に便利になるやつだった気がする
"  "neobundle 'shougo/context_filetype.vim'
"  "編集中のソースコードを非同期実行して、結果をみることが出来ます。必須だと思います。
"  "neobundle 'thinca/vim-quickrun
"  "ide的な、対応するカッコの自動入力だとかそういうものを設定しやすくしてくれます。個人的にはかなり愛用しているプラグインです。
"  "neobundle 'kana/vim-smartinput
"  "オペレーターとテキストオブジェクトをユーザが拡張しやすくしてくれるプラグインです。
"  "neobundle 'kana/vim-operator-user, kana/vim-textobj-user
"  "vim-operator-userを利用しています。vimに欠けている「クリップボードの文字列で対象の文字列を入れ替える」という機能を補ってくれます。
"  "neobundle 'kana/vim-operator-replace
"  "編集系の中でも最高のプラグインの一つであるsurround.vimの改良版です
"  "neobundle 'rhysd/vim-operator-surround
"  
  call neobundle#end()
   
   " 読み込んだプラグインも含め、ファイルタイプの検出、
   " ファイルタイプ別プラグイン/インデントを有効化する
   filetype plugin indent on
   
   syntax enable
   
   " installation check.
   if neobundle#exists_not_installed_bundles()
     echomsg 'not installed bundles : ' .
           \ string(neobundle#get_not_installed_bundle_names())
     echomsg 'please execute ":neobundleinstall" command.'
     "finish
   endif
   
   set shellslash
 
 endif

"---------------------------------------------------------------
" dein scripts
"
let s:dein_enabled  = 0
if !has('win32')
  let s:dein_enabled = 1
                                                                                          
  " Required:
  set runtimepath+=/home/enxajt/.cache/dein/repos/github.com/Shougo/dein.vim
  
  " Required:
  if dein#load_state('/home/enxajt/.cache/dein')
    call dein#begin('/home/enxajt/.cache/dein')
  
    " Let dein manage dein
    " Required:
    call dein#add('/home/enxajt/.cache/dein/repos/github.com/Shougo/dein.vim')
  
    " Add or remove your plugins here:
    call dein#add('Shougo/neosnippet.vim')
    call dein#add('Shougo/neosnippet-snippets')
  
    " You can specify revision/branch/tag.
    call dein#add('Shougo/vimshell', { 'rev': '3787e5' })
  
    " Required:
    call dein#end()
    call dein#save_state()
  endif
  
  " Required:
  filetype plugin indent on
  syntax enable
  
  " If you want to install not installed plugins on startup.
  if dein#check_install()
    call dein#install()
  endif
endif                                                                                   

""---------------------------------------------------------------
"" neocomplete
""
"note: this option must be set in .vimrc(_vimrc).  not in .gvimrc(_gvimrc)!
" disable autocomplpop.
let g:acp_enableatstartup = 0
" use neocomplete.
let g:neocomplete#enable_at_startup = 1
" use smartcase.
let g:neocomplete#enable_smart_case = 1
" set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $home.'/.vimshell_hist',
    \ 'scheme' : $home.'/.gosh_completions',
    \ '_' : $vimdir.'/dicts/engtojpn.dict',
        \ }

" define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" plugin key-mappings.
inoremap <expr><c-g>     neocomplete#undo_completion()
inoremap <expr><c-l>     neocomplete#complete_common_string()

" recommended key-mappings.
" <cr>: close popup and save indent.
inoremap <silent> <cr> <c-r>=<sid>my_cr_function()<cr>
function! s:my_cr_function()
  return (pumvisible() ? "\<c-y>" : "" ) . "\<cr>"
  " for no inserting <cr> key.
  "return pumvisible() ? "\<c-y>" : "\<cr>"
endfunction
" <tab>: completion.
inoremap <expr><tab>  pumvisible() ? "\<c-n>" : "\<tab>"
" <c-h>, <bs>: close popup and delete backword char.
inoremap <expr><c-h> neocomplete#smart_close_popup()."\<c-h>"
inoremap <expr><bs> neocomplete#smart_close_popup()."\<c-h>"
" close popup by <space>.
"inoremap <expr><space> pumvisible() ? "\<c-y>" : "\<space>"

" autocomplpop like behavior.
"let g:neocomplete#enable_auto_select = 1

" shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><tab>  pumvisible() ? "\<down>" : "\<c-x>\<c-u>"

" enable omni completion.
autocmd filetype css setlocal omnifunc=csscomplete#completecss
autocmd filetype html,markdown setlocal omnifunc=htmlcomplete#completetags
autocmd filetype javascript setlocal omnifunc=javascriptcomplete#completejs
autocmd filetype python setlocal omnifunc=pythoncomplete#complete
autocmd filetype xml setlocal omnifunc=xmlcomplete#completetags

" enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" for perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

""---------------------------------------------------------------
"" alignを日本語環境で使用するための設定
""
":let g:align_xstrlen = 3
"":alignctrl p0p0

"---------------------------------------------------------------
" key-mappings
"
" h map-modes
"
if has('win32')
  nmap <space>. :<c-u>tabedit $vim/_gvimrc<cr>
  nmap <space>, :<c-u>tabedit $vim/_vimrc<cr>
elseif has('unix')
  nmap <Space>, :<C-u>tabedit /root/neovim/share/nvim/sysinit.vim<CR>
endif

nmap <C-o><C-o> <ESC>i<C-r>=strftime(" %Y.%m.%d %H:%M:%S ")<CR><CR>

""---------------------------------------------------------------
"" key-mappings (junegunn/vim-easy-align)
""
"" repo = 'junegunn/vim-easy-align'
"" Start interactive EasyAlign in visual mode (e.g. vipga)
"" xmap ga <Plug>(EasyAlign)
"vmap <Enter> <Plug>(EasyAlign)
"" Start interactive EasyAlign for a motion/text object (e.g. gaip)
"nmap ga <Plug>(EasyAlign)
"
""---------------------------------------------------------------
"" key-mappings (neocomplete)
""
"" Plugin key-mappings.
"inoremap <expr><C-g>     neocomplete#undo_completion()
"inoremap <expr><C-l>     neocomplete#complete_common_string()
"
"" Recommended key-mappings.
"" <CR>: close popup and save indent.
"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"function! s:my_cr_function()
"  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
"  " For no inserting <CR> key.
"  "return pumvisible() ? "\<C-y>" : "\<CR>"
"endfunction
"" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"" <C-h>, <BS>: close popup and delete backword char.
"inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
"" Close popup by <Space>.
""inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"
"
"" For smart TAB completion.
""inoremap <expr><TAB>  pumvisible() ? "\<C-n>" :
""        \ <SID>check_back_space() ? "\<TAB>" :
""        \ neocomplete#start_manual_complete()
""  function! s:check_back_space() "{{{
""    let col = col('.') - 1
""    return !col || getline('.')[col - 1]  =~ '\s'
""  endfunction"}}}
"
"" AutoComplPop like behavior.
""let g:neocomplete#enable_auto_select = 1
"
"" Shell like behavior (not recommended.)
""set completeopt+=longest
""let g:neocomplete#enable_auto_select = 1
""let g:neocomplete#disable_auto_complete = 1
""inoremap <expr><TAB>  pumvisible() ? "\<Down>" :
"" \ neocomplete#start_manual_complete()
"
"---------------------------------------------------------------
" key-mappings (neosnippet)
"
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: "\<TAB>"
 
" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

"---------------------------------------------------------------
" unite
"
"インサートモードで開始
let g:unite_enable_start_insert = 1


""---------------------------------------------------------------
"" key-mappings (unite)
""
" 水平分割なら下に、垂直分割なら右に開く
let g:unite_split_rule = 'botright'

"nmap [unite] <Nop>
nmap <C-l> [unite]

"nmap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nmap <silent> [unite]o :<C-u>Unite -vertical -winwidth=40 outline<CR>
"nmap <silent> [unite]b :<C-u>Unite buffer<CR>
"nmap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>

" BOOKMARK
"nmap <silent> [unite]c :<C-u>Unite bookmark<CR>
"nmap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>

" most recently viewed files
" 保存数
let g:unite_source_file_mru_limit = 50
"file_mruの表示フォーマットを指定。空にすると表示スピードが高速化される
let g:unite_source_file_mru_filename_format = ''
nmap <silent> [unite]mt :<C-u>Unite file_mru -default-action=tabopen<CR>
nmap <silent> [unite]mv :<C-u>Unite file_mru -default-action=vsplit<CR>
nmap <silent> [unite]ms :<C-u>Unite file_mru -default-action=split<CR>
"nnoremap <leader>frt :Unite -quick-match file_mru -default-action=tabopen<CR>
"nnoremap <leader>frh :Unite -quick-match file_mru -default-action=split<CR>
"nnoremap <leader>frf :Unite -quick-match file_mru<CR>

"" 現在編集中のファイルが所属するプロジェクトのトップディレクトリ
"" (.git があったり Makefile があったり、configure があったりするディレクトリ)
"" を起点に unite.vim で file_recして、プロジェクトのファイル一覧を出力
"nmap <silent> [unite]p :<C-u>call <SID>unite_project('-start-insert')<CR>
"function! s:unite_project(...)
"  let opts = (a:0 ? join(a:000, ' ') : '')
"  let dir = unite#util#path2project_directory(expand('%'))
"  execute 'Unite' opts 'file_rec:' . dir
"endfunction

"uniteを開いている間のキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()

	"ESCでuniteを終了
	nmap <buffer> <ESC> <Plug>(unite_exit)

	"入力モードのときjjでノーマルモードに移動
	imap <buffer> jj <Plug>(unite_insert_leave)
	imap <buffer> kk <Plug>(unite_insert_leave)

	"入力モードのときctrl+wでバックスラッシュも削除
	imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

	"ctrl+jで縦に分割して開く
	nmap <silent> <buffer> <expr> <C-j> unite#do_action('split')
	inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')

	"ctrl+lで横に分割して開く
	nmap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
	inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')

	"ctrl+oでその場所に開く
	nmap <silent> <buffer> <expr> <C-o> unite#do_action('open')
	inoremap <silent> <buffer> <expr> <C-o> unite#do_action('open')

endfunction

"---------------------------------------------------------------
" key-mappings (vimfiler)
"
"noremap <C-r>t :VimFilerCurrentDir -split -simple -winwidth=45 -no-quit<ENTER>

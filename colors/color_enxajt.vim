" ↓3 下ほど明るい黄色
autocmd ColorScheme * highlight LineNr ctermfg=22 guifg=#666611
"autocmd ColorScheme * highlight LineNr ctermfg=22 guifg=#999955
"autocmd ColorScheme * highlight LineNr ctermfg=22 guifg=#F0E68C

"autocmd ColorScheme * highlight CursorLine ctermfg=235 guifg=#282a2e
autocmd ColorScheme * highlight CursorLineNr ctermfg=22 guifg=#999955
autocmd ColorScheme * highlight Visual ctermfg=22 guibg=#556600
autocmd ColorScheme * highlight Comment ctermfg=22 guifg=#a9a9a9

" white
"autocmd ColorScheme * highlight Normal ctermfg=22 guifg=#ffffff
" cornsilk fff8dc

"---------------------------------------------------------------
" 日本語入力
"
if has('multi_byte_ime') || has('xim')
  " IME ON時のカーソルの色を設定(設定例:紫)
  highlight CursorIM guibg=Purple guifg=NONE
  " 挿入モード・検索モードでのデフォルトのIME状態設定
  " 2:IMEon=日本語入力→切替可能　1:英語のみ 0:状態を保存
  set iminsert=0 imsearch=0
  if has('xim') && has('GUI_GTK')
    " XIMの入力開始キーを設定:
    " 下記の s-space はShift+Spaceの意味でkinput2+canna用設定
    "set imactivatekey=s-space
  endif
  " 挿入モードに入るとIME:on
  " コメントアウトで、挿入モードのIMEon/offを保存
  "inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
endif

"KaoriYa専用
"挿入モードから抜ける際、入る際に必ずIMEがオフになります。
"set imdisable

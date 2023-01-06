" abbrevations {{{
ab sysout System.out.println(
ab jnt @Test public void
ab pusf public static final
ab psf private static final
ab aT assertThat(
ab lggr private static final Logger log = LoggerFactory.getLogger( fn.class);
ab notimpl throw new UnsupportedOperationException("not implemented");
" }}}

if exists('g:JavaComplete_PluginLoaded')
	source /home/pi/.vim/config/javacomplete2.vim
endif

nnoremap <localleader>ht :! ctags -R .<CR>

let g:syntastic_java_checkers=['javac']
let g:syntastic_java_javac_config_file_enabled = 1

" map <leader>ss :execute "Ag -w --java " . expand("<cword>") <CR> 
" compiler gradle
set cindent
set tabstop=4
set shiftwidth=4
set smarttab
set noexpandtab
" 

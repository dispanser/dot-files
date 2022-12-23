nnoremap <localleader>ph ggi---<CR>title: <CR>author: Thomas Peiselt<CR>date: <CR>---<CR><CR>

nnoremap <localleader>la i\begin{align*}<CR>\end{align*}<ESC>O
" ab Rn \mathbb{R}^n
" ab Rnm \mathbb{R}^{n \times m}
" ab RR \mathbb{R}

inoremap Rn \mathbb{R}^n
inoremap Rnn \mathbb{R}^{n \times n}
inoremap Rnm \mathbb{R}^{n \times m}
inoremap Rmn \mathbb{R}^{m \times n}
inoremap RR \mathbb{R}
inoremap MAT \begin{bmatrix} \end{bmatrix}<ESC>F i
nmap <silent> <localleader>ta gaip*<BAR><CR>
g:pandoc#spell#default_langs=["de","en"]

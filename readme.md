# LocalIndentLie

**This plugin is inspired by [indentLine](https://github.com/Yggdroot/indentLine) and [local-indent.vim](https://github.com/tweekmonster/local-indent.vim).**



----

``` perl
use indentLine or local indentLine;
tell me, localIndentLie;
my localIndentLie;
```

![Example](https://github.com/FloatingLion/LocalIndentLie.vim/blob/master/test/example.gif)

### Q：它是开箱即用的吗？

A：不是的，你需要用命令`:LocalIndentLieOn`来打开LocalIndentLie，用`:LocalIndentLieOff`来关闭它。你也可以将

```vim
autocmd FileType python,haskell
      \ LocalIndentLieOn
" 或者对所有文件启用
autocmd FileType * LocalIndentLieOn
```

添加到你的配置文件`$MYVIMRC`里。如果你还是不放心，可以用`:LocalIndentLieStatus`命令来确认当前LocalIndentLie的状态。

### Q：为什么我的缩进线是混乱的？

A：LocalIndentLie依赖按空格的缩进，tab缩进总是得不到正确的行为。这意味着你的vim应当已经设置了`expandtab`选项。如果你没有特别的缩进信仰，请确保你的配置文件中已有

```vim
" 选择任意你喜欢的缩进长度
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
```

另外，LocalIndentLie是脆弱的，即使你设置了`expandtab`，也请确保你的遗留代码中没有tab。

### Q：可是有些文件需要tab，比如snippet

A：是的，所以我们建议只在部分`FileType`中使用LocalIndentLie。:)

### Q：为什么在Backspace的时候会花屏？

A：我也在vim里遇到了这个情况，但是在nvim里面一切正常，我还不能断言这是什么问题。如果这还在你的容忍范围之内，可以使用`g:localIndentLie_insertDisable`来缓解一下心情，它将禁用`Insert-Mode`中的LocalIndentLie。

```vim
let g:localIndentLie_insertDisable = 1 " Default 0
```

### Q：这条缩进线不太好看

A：你可以使用`g:localIndentLie_char`来指定缩进线用到的字符

```vim
let g:localIndentLie_char = '┊' " '|', '¦', '┆',...
```

默认地，缩进线的颜色会使用你的Operator高亮组样式，你也可以用`g:localIndentLie_termColor`或者`g:localIndentLie_guiColor`来选择你喜欢的颜色

```
let g:localIndentLie_termColor = 240
let g:localIndentLie_guiColor  = 'grey' " or '#RRGGBB'
```

更多的颜色选项参见`:help ctermcolors`或者`:help guicolors`

### Q：嗯，但是它还是存在各种各样的问题

A：嗯，作者会尽量让它看起来没有问题。或许你可以尝试一下上面提到的[indentLine](https://github.com/Yggdroot/indentLine)和[local-indent.vim](https://github.com/tweekmonster/local-indent.vim)，它们更成熟也更稳定。如果对LocalIndentLie有建议，也请不吝赐教。

### Q：好吧，它还有什么配置选项吗？

A：LocalIndentLie使用了`conceal`，它会链接你的`Conceal`高亮组，并（在使用期间）调整你的`conceallevel`和`concealcursor`选项，如果你想使用自己的配置，用

```vim
let g:localIndentLie_useconceal = 0 " Default 1
```

禁用它们。但这也意味着你`g:localIndentLie_termColor`和`g:localIndentLie_guiColor`会不再起作用。如果你不了解这个特性，建议使用默认值。

### Q：最后还有什么想说的吗？

**HAPPY INDENT!**

----

### License

MIT


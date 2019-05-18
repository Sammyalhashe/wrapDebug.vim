# Wrap debug plugin

- This plugin wraps selected text with print statements of the current language (based on filetype).
- The plugin works in normal mode and visual mode.
- In ``normal`` mode, the text under the cursor will be chosen to be wrapped.
- In ``visual`` mode, the selected text will be chosen.
- This is best explained as an example:

<img src="https://media.giphy.com/media/dyL10l9AM80FBQACdt/giphy.gif" width="600" height="600">

## Mappings
- By default, the mapping to execute the wrapping function is `<c-q>` (control-q).
- To re-map this, set the variable `g:wrap_mapping` to your desired mapping.
- The variable `g:print_mappings` is a dictionary that stores what syntax you want for each language. It defaults as:

```vim
{
\ "python": "print", 
\ "javascript.jsx": "console.log", 
\ "typescript": "console.log", 
\ "vim": "echomsg string", 
\ "cpp": "std::cout"
\ }
```

- The variable `g:brackets` does the same except it store what surrounding parentheses you want for each language. It defaults to:

```vim
{"python": "()", 
\ "javascript.jsx": "():", 
\ "typescript": "();", 
\ "vim": "()", 
\ "cpp": [" << ", ' << "\n";']
\ }
```
- Since the surrounding parenthesis for `cpp` involve more than one character, use lists instead of strings.
- By default, the plugin creates a copy of the selected text and places the `print` statement on the line above. If you want to only surround the selected text, set `g:keep_copy = 0`.


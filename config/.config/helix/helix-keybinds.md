# Helix Keybinds

## Independent
% = select all

u = undo
U = redo
w = move cursor forward word by word
b = move cursor backward word by word
x = highlight line
d = delete / cut
c = change
y = copy

wd = delete word
wc = change word
% -> s -> c = select all -> select -> change all selected

t-(char) = move cursor and select up to written char
v = select mode
/ = search
=> n = goto next match
=> N = goto prev match

## G - Goto
g = go to first line
e = go to last line
h = go to line start
l = go to line end
d = go to definition
w = jump to a label with 2 char

## Space
a = perform code action on normal mode
b = show opened buffers
? = keybind guide (%binding for keybind search)
f = file picker
=> C-v = open file in vertical split
s = symbol picker
S = symbol picker in project
d = diagnostic picker
r = rename symbol
/ = global search

## Ctrl
x = perform code action on insert mode
c = comment in/out

## Alt
o / up = expand selection to parent syntax
i / down = shrink selection to prev expanded syntax

## M - Match
i = select inside object
s = surround add
r = surround replace
d = surround delete

## Custom
C-g = open lazygit
S-w = write
S-q = quit
A-j = move line down
A-k = move line up
Sh-h = prev buffer
Sh-l = next buffer

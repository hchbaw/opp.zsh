<img src="https://github.com/hchbaw/opp.zsh/raw/readme/ciw.png" />

<pre>
vim's text-objects-ish for zsh.

Author: Takeshi Banse &lt;takebi@laafc.net&gt;
License: Public Domain

Thank you very much, Bram Moolenaar!
I want to use the vim's text-objects in zsh.

To use this,
1) source this file.
% source opp.zsh
2) If you wish to load the extensions, source them afterward.
% source opp/*.zsh
*Optionally* you can use the zcompiled file with the autoloading for a
little faster loading on every shell start up, if you zcompile the
necessary functions.
*1) Prepare zcompiling the defined functions and the install command.
% OS=(~/path/to/opp.zsh/{opp.zsh,opp/*.zsh})
*2) If you have some opp/surround.zsh's configurations, those
configurations could be zcompiled at this point. Assuming you have such a
configuration file in ~/.zsh/opp-surround.zsh, you could do this.
% OS=(~/path/to/opp.zsh/{opp.zsh,opp/*.zsh} ~/.zsh/opp-surround.zsh(N))
*3) Generate the ~/.zsh/zfunc/{opp,opp-install}.zwc.
% (zsh -c "for O in $OS;do . $O;done && opp-zcompile $OS[1] ~/.zsh/zfunc"
set up an autaload clause appropriately.
% { . ~/.zsh/zfunc/opp-install; opp-install }
% autoload opp

Note:
This script replaces below vicmd key map entries.
  ~, c, d, gu, gU and y
Please beware of.

Extension:

opp/textobj-between.zsh
http://d.hatena.ne.jp/thinca/20100614/1276448745
http://d.hatena.ne.jp/tarao/20100715/1279185753
Thank you very much, thinca and tarao!

opp/surround.zsh
Thank you very much tpope!
http://www.vim.org/scripts/script.php?script_id=1697

TODO: in case these (ci" with improper double quotes) situations.
TODO: operator (currently ~, c, d, gu, gU and y)
TODO: o_v o_V o_CTRL_V
TODO: as is op ip at it

History

v0.0.7
Add ~, gu and gU.
Paren-matching operation fixes.

v0.0.6
Add opp/surround.zsh

v0.0.5
Add opp/textobj-between.zsh
Add `opp-installer-add' for the extensions.
Add aw aW iW and fix iw.

v0.0.4
Add textobj-between link.

v0.0.3
Cleanup inbetween codes.

v0.0.2
Fix cc dd yy not work bug.

v0.0.1
Initial version.
</pre>

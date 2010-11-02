<img src="http://github.com/hchbaw/opp.zsh/raw/readme/ciw.png" />

<pre>
vim's text-objects-ish for zsh.

Author: Takeshi Banse &lt;takebi@laafc.net&gt;
Licence: Public Domain

Thank you very much, Bram Moolenaar!
I want to use the vim's text-objects in zsh.

To use this,
1) source this file.
% source opp.zsh
*Optionally* you can use the zcompiled file with the autoloading for a
little faster loading on every shell startup, if you zcompile the
necessary functions.
*1) zcompile the defined functions and the install command.
(generates ~/.zsh/zfunc/{opp,opp-install}.zwc)
% O=~/path/to/opp.zsh; (zsh -c "source $O && opp-zcompile $O ~/.zsh/zfunc")
*2) source the zcompiled install command file insted of this file.
% source ~/.zsh/zfunc/opp-install; opp-install

Note:
This script replaces vicmd kepmap entries(c, d and y). Please beware of.

Extension:

opp/textobj-between.zsh
http://d.hatena.ne.jp/thinca/20100614/1276448745
http://d.hatena.ne.jp/tarao/20100715/1279185753
Thank you very much, thinca and tarao!

TODO: in case these (ci" with improper double quotes) situations.
TODO: operator (currently c, d and y)
TODO: o_v o_V o_CTRL_V
TODO: as is op ip at it

History

v0.0.5
Add opp/textobj-between.zsh
Add `opp-installer-add' for the extentions.
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

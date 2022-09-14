#{}:
{
	# quick dir changes
	".." = "cd ..";
	"..." = "cd ../..";
	"...." = "cd ../../..";
	"....." = "cd ../../../..";
	
	# coloration
	ls = "ls --color=auto";
	grep = "grep --color=auto";
	ll = "ls -lAh --color=auto";
	
	# verbosity and human readable
	df = "df -h";
	du = "du -ch";
	cp = "cp -v";
	mv = "mv -v";
	
	# don't destroy my computer
	rm = "rm -Iv --preserve-root";
	chown = "chown --preserve-root";
	chmod = "chmod --preserve-root";
	chgrp = "chgrp --preserve-root";
	
	# quick stuff
	v = "nvim";
	c = "clear";
	q = "exit";
	mx = "chmod +x";

    # places
	lab = "cd ~/lab";
    scratch = "cd ~/lab/_env/scratchpad";
	
	# tmux
	tn = "tmux new-session -s";
	ta = "tmux attach -t";
	tl = "tmux ls";
	tk = "tmux kill-session -t";
	tc = "tmux new-session -t";

	# git
	g = "git status";
	ga = "git add -A";
	gc = "git commit -a";
	gu = "git push";
	gd = "git pull";
	gl = "git log --oneline -n 10";


  mm = "micromamba";
  conda = "micromamba";
}

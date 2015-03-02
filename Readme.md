FileBot
=======

Extensible Bash bot to serve your sysadmin jobs quick and easily.

FileBot was born as small project to scan WordPress upload's dir and to remove
evil file that malicious users can put there.
The initial idea was extended to accmplish more versatile tasks and the script
was extended to be a generic robot to play configurable actions based on well
known and easy readible Yaml file.

The current structure includes:
- Config file inside config dir (!)
- Project dependencies under vendor dir
- A testfile dir with some example files to check how the script works
- And for sure the main script: fialbot.sh

The confguration file in Yaml format, is parsed with a well faetured
Python project called Shyaml:
https://github.com/0k/shyaml

The project is on going stage at the moment, and it should be considered at his
early stage, feel free to contruibuite and add your ideas !

Happy hacking!

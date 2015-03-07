<img src="https://openclipart.org/download/194634/Friendly-Robot-Remix-by-Merlin2525.svg" alt="FileBot" width="40%" height="40%">

#FileBot

Extensible Bash bot to serve your sysadmin jobs quick and easily.

FileBot was born as small project to scan WordPress upload's dir and to remove
evil files that malicious users can put there.
The initial idea was extended to accmplish more complex and versatile tasks.
The script was extended to be a generic robot to play configurable actions on files 
based on well known Yaml configuration file.

The current structure includes:
- The main script: fialbot.sh
- Config file inside config dir (!)
- Project dependencies under vendor dir
- A testfile dir with some example files to check how the script works

The confguration file in Yaml format, is parsed with a well faetured
Python project called **Shyaml**: [https://github.com/0k/shyaml](https://github.com/0k/shyaml)

####How it works
The general idea is to scan dir's and check every file mime-type, if the found mime-type is in the configuration file, the configured action is fired against the file.
An example: let's suppose you want to scan a WordPress upload dir for malicious files, reasonably you don't want executable file to be there.
You have to configure the mime-type of the executable file, let's say `text/x-php`, you can configure an *action* to delete the evil file.
The action actually is a Bash function that performs a series of task against the file.

As you can imagine after the action is performed some things will happen: you can configure log files ad email notifications.

Everything is managed thoutght the configuration file, here's an example:
<pre>
</pre>

More implementations will come, your contribuitions are welcome !

Last note: the current logo is courtesy of: **[openclipart.org](https://openclipart.org/download/194634/Friendly-Robot-Remix-by-Merlin2525.svg  "FileBot")**
## EIT PHP Project Initializer

This project contains templates and a script to initialize files for a
new PHP project following the following conventions.  To start a new
project with it, run ```bin/create-project -i```
(you can run it from anywhere; it will find the templates relative to
whatever path you give to ```create-project```).
It will prompt you for a project name
(type it like you would in your native language, e.g. "Bob's Cool
Thinger") and a namespace with which to prefix all your
project-specific classes (e.g. "Bob_CoolThinger"), and then create a
bunch of files to get you started.

This can be used to rewrite any project that contains a
```.ppi-settings.json``` and ```.ppi-settings-metadata.json``` file,
but by default will pull down and use a recent version of
[PHPTemplateProject](http://github.com/EarthlingInteractive/PHPTemplateProject)

To get started with your PHPTemplateProject right away, run
```bin/create-project -i --make everything```.  This will attempt to
```sudo``` to the ```postgres``` user to create your database, run the
upgrade scripts, run the unit tests, and start a web server.

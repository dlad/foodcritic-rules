#foodcritic-rules
================

These are foodcritic that we've written at [The Cloud](http://www.thecloud.net/). The rules have been developed based on our experiences with writing cookbooks.

# Rules

## TC001 - Version number should be updated if a cookbook is changed

This one is a pain as it means you have to remember to bump version numbers with each change but it has saved our bacon on a few occasions. Works well in combination with banning merge commits in your chef repo.

## TC002 - Debugging statements should be removed

This command detects leftover `puts`, `pp` and `print` statements.

For example, this block would trip this rule:

````
puts "foo"
````

## TC003 - Chef managed files should state as such

It is very easy to make changes to a deployed file that is chef managed only to lose them when `chef-client` runs again. Having this notice serves as a nice reminder so you don't forget.

The text `this file is chef managed` should appear within the first five lines of the file or template.

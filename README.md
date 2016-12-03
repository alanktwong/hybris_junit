# hybris_junit

A convenience Ruby script to run junit tests 

### Running unit tests with a Ruby CLI tool

Alternatively a Ruby CLI tool which wraps the above has been written and checked in to make a lot of this easier. To use it:
* Go to the hybris/bin/platform directory
* Soft link to: `junit.rb@ -> ../../../tools/junit-cli/junit.rb`
* Copy the YML configurations to hybris/bin/platform, so that you can modify as you need: `cp ../../../tools/junit-cli/junit_cfg.yml.template junit_cfg.yml`
*To use the tool, `hybris/bin/platform/junit.rb --help`
```
Usage: junit [options]
Hybris JUNIT CLI Runner v1.0.0
Specific options:
    -b, --both 0,1,...               Run both integration/unit tests on a list of extensions defined in junit_cfg.yml
                                     as an array under the property called all_extensions.
                                     Extensions to run are selected by a 0-based index.
    -w, --web 0,1,...                Run both integration/unit tests on a list of web extensions defined in junit_cfg.yml
                                     as an array under the property called all_extensions as well as in webExtensions.
                                     Extensions to run are selected by a 0-based index.
    -u, --unit 0,1,...               Run unit tests on a list of extensions defined in junit_cfg.yml
                                     as an array under the property called all_extensions
                                     Extensions to run are selected by a 0-based index.
    -p, --package 0,1,...            Run unit tests on a list of packages defined in junit_cfg.yml
                                     as an array under the property called all_packages.
                                     Packages to run are selected by a 0-based index.
    -v, --[no-]verbose               This boolean flag sets verbosity to either true or false.
        --[no-]enabled               This boolean flag enables whether ant is run
    -t, --test                       Run all tests in all packages defined in junit_cfg.yml
                                     as an array under the property called all_packages
    -a, --all                        Run all tests in all extensions defined in junit_cfg.yml
                                     as an array under the property called all_extensions
    -h, --help, --usage              Show this usage message and quit.
        --version                    Show version information about this program and quit.
```
So if your `junit_cfg.yml` has:
```
all_extensions:
- mycustomcore
- mycustomfacades
- mycustomwebservices
- mycustominitialdata
- mycustomfulfilmentprocess=
- mycustomcockpit
- mycustombackoffice
- mycustomstorefront
webExtensions:
- mycustomwebservices
- mycustomstorefront
all_packages:
- com.custom.core.MyCustomServiceImplTest
=```
You can run unit tests on just MyCustomServiceImplTest, by invoking `junit.rb -p 0`
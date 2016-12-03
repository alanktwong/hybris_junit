# hybris_junit

A convenience Ruby script to run junit tests 

### Running unit tests with a Ruby CLI sript

This is a Ruby CLI script to make running unit tests for Hybris projects easier. To set it up for yourself:
* Go to the hybris/bin/platform directory
* Create a soft link such that: `hybris/bin/platform/junit.rb@ -> path/to/hybris_junit/junit.rb`
* Copy the YML configurations so that you can modify as you need. E.g. `cp path/to/hybris_junit/junit_cfg.yml hybris/bin/platform/junit_cfg.yml`
* To use the tool, `hybris/bin/platform/junit.rb --help`

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
- mycustomfulfilmentprocess
- mycustomcockpit
- mycustombackoffice
- mycustomstorefront
webExtensions:
- mycustomwebservices
- mycustomstorefront
all_packages:
- com.custom.core.MyCustomServiceImplTest
- com.custom.core.MyCustomDaoImplTest
- com.custom.core.MyCustomFacadeImplTest
```

Thus
* You can run unit tests on just MyCustomServiceImplTest and MyCustomFacadeImplTest, by invoking `hybris/bin/platform/junit.rb -p 0,2`.
* You can run unit tests on just mycustomcore by invoking `hybris/bin/platform/junit.rb -u 0`
* Unfortunately, tests stored in `web/testsrc` directories need to be run separately than the ones stored in `testsrc` directory. Hence to run unit tests on just mycustomwebservices and  mycustomstorefront, invoke `hybris/bin/platform/junit.rb -w 0,1`
* The command line tool accepts array indices as a comma-separated list of integers. It does not have the ability to deal with ranges.



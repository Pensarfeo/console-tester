# console-tester

Console tester is a very small gem / "bounch of files put together in a gem like form" that tries to reproduce the test environment (exclusively tested with minitest) in the rails test console.
The project is highly experimental so use with discretion.
The file reloading is a bit funky and the gem has so far only been tested with models and controllers.

Usage:

To use this gem write a test_data.rb in your test directory. with a content of the type

@tests_list={models: [:model1, ... ,:modeln]], controllers: [:controller1, ... ,controllern] ] }
the file structure in the test file should follow the one described in the @test_list variable.
also the files should be named, for example as: model1_test.rb.





require('coffee-script/register');

var gulp = require('gulp'),
    mocha = require('gulp-mocha'),
    coffeelint = require('gulp-coffeelint'),
    releaseTasks = require('gulp-release-tasks');

// Load tasks into gulp
releaseTasks(gulp);

var paths = {
    scripts: ['index.coffee', 'src/**/*.coffee'],
    tests: ['test/**/*.coffee']
  };

gulp.task('lint', function () {
  gulp.src(paths.scripts)
  .pipe(coffeelint())
  .pipe(coffeelint.reporter())
});

gulp.task('watch', function() {
  gulp.watch(paths.scripts, ['test']);
  gulp.watch(paths.tests, ['test']);
});

gulp.task('test', ['lint'], function() {
return gulp.src(paths.tests, {read: false})
  .pipe(mocha());
});


gulp.task('default', ['test']);

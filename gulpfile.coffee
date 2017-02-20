gulp   = require 'gulp'
$      = require('gulp-load-plugins')()

pkg = require './package.json'
autoprefixer = require 'autoprefixer'

## custom config
tmp_dir  = '.tmp'
src_dir  = 'lib'
dist_dir = 'dist'
config =
  # path
  tmp:
    dir: tmp_dir
    css: "#{tmp_dir}/css"
    js : "#{tmp_dir}/js"
  src:
    dir   : src_dir
    coffee: "#{src_dir}/coffee"
    scss  : "#{src_dir}/scss"
    images: "#{src_dir}/images"
    # fonts : "#{src_dir}/fonts"
    bower : "bower_components"
  dist:
    dir   : dist_dir
    js    : 'application.js'
    css   : 'style.css'
    images: "#{dist_dir}/images"
    fonts : "#{dist_dir}/fonts"
  # postcss and autoprefixer
  processors: [
    autoprefixer
      browsers: [
        'last 2 versions'
        'ie 8'
        'ie 9'
        'ie 10'
      ]
  ]
  # banner
  banner: """
  /*!
   * Theme Name:
   * Theme URI: https://
   * Author: Taiki Niimi
   * Author URI: http://nm-tk.net
   * Description: The theme for Takuyuki Saito
   * Version: <%= pkg.version %>
   * License: Distribution prohibited.
   */
  """

## development or distribution
dist = ->
  return process.env['GULP_ENV'] == 'dist'

gulp.task 'js', ->
  paths =
  [
    "#{config.src.coffee}/**/*.coffee"
    "#{config.src.bower}/css-browser-selector/css_browser_selector.js"
  ]
  gulp.src paths
    .pipe $.plumber
      errorHandler: $.notify.onError "<%= error.message %>"
    .pipe $.if(/[.]coffee$/, $.coffee())
    .pipe $.concat(config.dist.js)
    #.pipe $.banner config.banner, pkg: pkg
    .pipe $.if dist, $.uglify
      preserveComments: 'license'
    .pipe gulp.dest(config.dist.dir)
    # .pipe $.notify "Create application.js!"

gulp.task 'css', ->
  gulp.src "#{config.src.scss}/**/*.scss"
    .pipe $.plumber
      errorHandler: $.notify.onError "<%= error.message %>"
    .pipe $.compass
      bundle_exec: true
      style: 'nested'
      comments: true
      relative: true # default
      css  : config.tmp.css
      sass : config.src.scss
      image: config.src.images
      font : config.src.fonts
      javascript: config.tmp.js
    .pipe $.concat(config.dist.css)
    .pipe $.postcss(config.processors)
    .pipe $.combineMq()
    .pipe $.csscomb()
    #.pipe $.banner config.banner, pkg: pkg
    .pipe $.if dist, $.csso()
    .pipe gulp.dest(config.dist.dir)
    # .pipe $.notify "Create style.css!"

gulp.task 'copy', ->
  gulp.src "#{config.src.dir}/{images,fonts}/**/*"
    .pipe $.plumber
      errorHandler: $.notify.onError "<%= error.message %>"
    .pipe gulp.dest(config.dist.dir)
    .pipe $.notify "Copy images and fonts directory!"

gulp.task 'watch', ->
  $.watch "#{config.src.coffee}/**/*.coffee",      (e) -> gulp.start 'js'
  $.watch "#{config.src.scss}/**/*.scss",          (e) -> gulp.start 'css'
  $.watch "#{config.src.dir}/{images,fonts}/**/*", (e) -> gulp.start 'copy'

gulp.task 'default', ->
  ['js', 'css', 'copy', 'watch'].forEach (tsk, index, array) ->
    gulp.start tsk

gulp.task 'dist', ->
  process.env['GULP_ENV'] = 'dist'
  ['js', 'css', 'copy'].forEach (tsk, index, array) ->
    gulp.start tsk

const mix = require('laravel-mix');

mix.sass('resources/sass/hitch_prim.scss', 'public/css')
   .sass('resources/sass/hitch.scss', 'public/css');
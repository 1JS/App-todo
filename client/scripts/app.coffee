'use strict'

angular.module('app', [
    # Angular modules
    'ngRoute'
    'ngAnimate'

    # Custom modules
    'app.task'
])

.config([
    '$routeProvider'
    ($routeProvider) ->
        $routeProvider
            .when(
                '/'
                templateUrl: 'views/main.html'
            )

            .otherwise(
                redirectTo: '/'
            )
])
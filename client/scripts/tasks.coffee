'use strict'

angular.module('app.task', [])

.factory('taskStorage', ->
    STORAGE_ID = 'tasks'
    DEMO_TASKS = '[
        {"title": "Finish homework", "completed": true},
        {"title": "Make a call", "completed": true},
        {"title": "Play games with friends", "completed": false},
        {"title": "Shopping", "completed": false}
    ]'

    return {
        get: ->
            JSON.parse(localStorage.getItem(STORAGE_ID) || DEMO_TASKS )

        put: (tasks)->
            localStorage.setItem(STORAGE_ID, JSON.stringify(tasks))
    }
)

# cusor focus when dblclick to edit
.directive('taskFocus', [
    '$timeout'
    ($timeout) ->
        return {
            link: (scope, ele, attrs) ->
                scope.$watch(attrs.taskFocus, (newVal) ->
                    if newVal
                        $timeout( ->
                            ele[0].focus()
                        , 0, false)
                )
        }
])

.controller('taskCtrl', [
    '$scope', 'taskStorage', 'filterFilter', '$rootScope'
    ($scope, taskStorage, filterFilter, $rootScope) ->

        tasks = $scope.tasks = taskStorage.get()

        $scope.newTask = ''
        $scope.remainingCount = filterFilter(tasks, {completed: false}).length
        $scope.editedTask = null
        $scope.statusFilter = {completed: false}

        $scope.filter = (filter) ->
            switch filter
                when 'all' then $scope.statusFilter = ''
                when 'active' then $scope.statusFilter = {completed: false}
                when 'completed' then $scope.statusFilter = {completed: true}

        $scope.add = ->
            newTask = $scope.newTask.trim()

            if newTask.length is 0
                return

            tasks.push(
                title: newTask
                completed: false
            )

            taskStorage.put(tasks)

            $scope.newTask = ''
            $scope.remainingCount++

        $scope.edit = (task)->
            $scope.editedTask = task

        $scope.doneEditing = (task, $index) ->
            $scope.editedTask = null
            task.title = task.title.trim()

            if !task.title
                $scope.remove(task, $index)

            taskStorage.put(tasks)

        $scope.remove = (task, $index) ->
            $scope.remainingCount -= if task.completed then 0 else 1
            tasks.splice($index, 1)
            taskStorage.put(tasks)

        $scope.completed = (task) ->
            $scope.remainingCount += if task.completed then -1 else 1
            taskStorage.put(tasks)
            # if task.completed
            #     if $scope.remainingCount > 0
            #         if $scope.remainingCount is 1
            #             toastr.info('Almost there! Only ' + $scope.remainingCount + ' task left')
            #         else
            #             toastr.info('Good job! Only ' + $scope.remainingCount + ' tasks left')
            #     else
            #         toastr.success('Congrats! All done :)')

        $scope.clearCompleted = ->
            $scope.tasks = tasks = tasks.filter( (val) ->
                return !val.completed
            )
            taskStorage.put(tasks)

        $scope.markAll = (completed)->
            tasks.forEach( (task) ->
                task.completed = completed
            )
            $scope.remainingCount = if completed then 0 else tasks.length
            taskStorage.put(tasks)
            # if completed
            #     toastr.success('Congrats! All done :)')

        $scope.$watch('remainingCount == 0', (val) ->
            $scope.allChecked = val
        )

        $scope.$watch('remainingCount', (newVal, oldVal) ->
            $rootScope.$broadcast('taskRemaining:changed', newVal) 
        )
])
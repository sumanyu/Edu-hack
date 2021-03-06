Template.fileSharing.helpers
  sharedFiles: ->
    result = getCurrentClassroomSession(['sharedFiles'])?.sharedFiles || []

Template.fileSharing.events
  "click .drag-and-drop-files": (e) ->
    # $('input[type=file]').click()

  "drop .drag-and-drop-files": (e) ->
    e.preventDefault()
    e.stopPropagation()
    _.each e.dataTransfer.files, uploadFileToS3

  "dragover .drag-and-drop-files": (e) ->
    e.preventDefault()
    e.stopPropagation()
    e.dataTransfer.dropEffect = 'copy'

  "click .delete-file": (e) ->
    path = $(e.target).data('path')
    if path
      Meteor.call 'deleteFileFromClassroomSession', Session.get('classroomSessionId'), path